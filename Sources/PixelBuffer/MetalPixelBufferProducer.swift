//
//  MetalPixelBufferProducer.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 11/03/2019.
//  Copyright © 2020 GORA Studio. https://gora.studio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import AVFoundation
import MetalPerformanceShaders
import UIKit

final class MetalPixelBufferProducer {

  typealias CVPixelBufferResult = Result<CVPixelBuffer, Swift.Error>

  enum Error: Swift.Error {

    case noDevice

    case noCommandQueue

    case noCommandBuffer

    case noLastTexture

    case noSurface

    case noSourceTexture

    case commandBufferError(_ error: Swift.Error?)
  }

  let device: MTLDevice

  let recordableLayer: RecordableLayer

  let queue: DispatchQueue

  var videoColorProperties: [String: String]? {
    recordableLayer.pixelFormat.supportedPixelFormat.videoColorProperties
  }

  var videoTransform: CGAffineTransform {
    guard recordableLayer.framebufferOnly else { return .identity }
    switch recordableLayer.interfaceOrientation {
    case .unknown, .portrait:
      return .identity
    case .landscapeLeft:
      return CGAffineTransform.identity
        .rotated(by: .pi / 2.0)
//        .scaledBy(x: 1.0, y: -1.0)
    case .landscapeRight:
      return CGAffineTransform.identity
        .rotated(by: -.pi / 2.0)
//        .scaledBy(x: 1.0, y: -1.0)
    case .portraitUpsideDown:
      return .identity
    @unknown default:
      return .identity
    }
  }

  var imageOrientation: UIImage.Orientation {
    guard recordableLayer.framebufferOnly else { return .up }
    switch recordableLayer.interfaceOrientation {
    case .unknown, .portrait: return .up
    case .landscapeLeft: return .right
    case .landscapeRight: return .left
    case .portraitUpsideDown: return .down
    @unknown default: return .up
    }
  }

  lazy var commandQueue: MTLCommandQueue? = device.makeCommandQueue()

  lazy var metalTexturePoolFactory = MetalTexturePoolFactory.getWeaklyShared(device: device)

  init(recordableLayer: RecordableLayer, queue: DispatchQueue) throws {
    guard let device = recordableLayer.device else { throw Error.noDevice }

    self.device = device
    self.recordableLayer = recordableLayer
    self.queue = queue
  }

  func produce(handler: @escaping (CVPixelBufferResult) -> Void) throws {
    guard let commandQueue = commandQueue else { throw Error.noCommandQueue }
    try produce(using: commandQueue, handler: handler)
  }

  func produce(
    using commandQueue: MTLCommandQueue,
    handler: @escaping (CVPixelBufferResult) -> Void
  ) throws {
    guard let lastTexture = recordableLayer.lastTexture else { throw Error.noLastTexture }
    guard let surface = lastTexture.iosurface else { throw Error.noSurface }

    let sourceTextureDescriptor = self.makeSourceTextureDescriptor(basedOn: lastTexture, surface: surface)
    guard let sourceTexture = self.device.makeTexture(
      descriptor: sourceTextureDescriptor,
      iosurface: surface,
      plane: 0
    ) else {
      throw Error.noSourceTexture
    }

    let attachements = self.makePixelBufferAttachements(basedOn: surface)
    let metalTexturePool = try self.makeMetalTexturePool(basedOn: lastTexture, surface: surface)
    let destinationTexture = try metalTexturePool.getMetalTexture(propagatedAttachments: attachements)

    queue.async { [weak self] in
      do {
        try self?.produce(
          using: destinationTexture,
          from: sourceTexture,
          commandQueue: commandQueue,
          handler: handler
        )
      }
      catch {
        handler(.failure(error))
      }
    }
  }

  func produce(
    using destinationTexture: MetalTexture,
    from sourceTexture: MTLTexture,
    commandQueue: MTLCommandQueue,
    handler: @escaping (CVPixelBufferResult) -> Void
  ) throws {

    guard let commandBuffer = commandQueue.makeCommandBuffer() else { throw Error.noCommandBuffer }

    let imageConversion = self.makeImageConversion(
      sourceTexture: sourceTexture,
      destinationTexture: destinationTexture.mtlTexture
    )

    imageConversion.encode(
      commandBuffer: commandBuffer,
      sourceTexture: sourceTexture,
      destinationTexture: destinationTexture.mtlTexture
    )

    commandBuffer.addCompletedHandler { [weak self] (commandBuffer) in
      let result: CVPixelBufferResult = commandBuffer.status == .completed
        ? .success(destinationTexture.pixelBuffer.cvPxelBuffer)
        : .failure(Error.commandBufferError(commandBuffer.error))
      self?.queue.async { handler(result) }
    }
    commandBuffer.commit()
  }

  func makeMetalTexturePool(basedOn texture: MTLTexture, surface: IOSurface) throws -> MetalTexturePool {
    try metalTexturePoolFactory.getMetalTexturePool(
      width: surface.width,
      height: surface.height,
      pixelFormat: texture.pixelFormat.supportedPixelFormat
    )
  }

  func makeSourceTextureDescriptor(basedOn texture: MTLTexture, surface: IOSurface) -> MTLTextureDescriptor {
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: texture.pixelFormat,
      width: surface.width,
      height: surface.height,
      mipmapped: false
    )
    textureDescriptor.usage = .shaderRead
    if #available(iOS 13.0, *) {
      textureDescriptor.hazardTrackingMode = .untracked
    }
    return textureDescriptor
  }

  func makePixelBufferAttachements(basedOn surface: IOSurface) -> [String: Any] {
    var attachements = (try? PixelBuffer(surface).propagatedAttachments) ?? [:]

    let colorSpaceKey = kCVImageBufferCGColorSpaceKey as String
    // swiftlint:disable force_cast
    var colorSpace = attachements[colorSpaceKey].map({ $0 as! CGColorSpace })
    // swiftlint:enable force_cast
    colorSpace = colorSpace ?? recordableLayer.colorspace

    attachements[colorSpaceKey] = colorSpace
    attachements[kCVImageBufferICCProfileKey as String] = colorSpace?.copyICCData()

    return attachements
  }

  func makeImageConversion(
    sourceTexture: MTLTexture,
    destinationTexture: MTLTexture
  ) -> MPSImageConversion {
    MPSImageConversion(
      device: device,
      srcAlpha: sourceTexture.pixelFormat.alphaType,
      destAlpha: destinationTexture.pixelFormat.alphaType,
      backgroundColor: nil,
      conversionInfo: nil
    )
  }
}
