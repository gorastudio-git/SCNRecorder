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

final class MetalPixelBufferProducer {

  enum Error: Swift.Error {

    case noTexture

    case noSurface

    case noBytes

    case framebufferOnly

    case baseAddress
  }

  var size: CGSize { recordableLayer.drawableSize }

  var videoColorProperties: [String: String]? { recordableLayer.pixelFormat.videoColorProperties }

  let recordableLayer: RecordableLayer

  let queue: DispatchQueue

  lazy var pixelBufferPoolFactory = PixelBufferPoolFactory.getWeaklyShared()

  lazy var emptyBuffer = Buffer.zeroed(size: 0)

  init(recordableLayer: RecordableLayer, queue: DispatchQueue) {
    self.recordableLayer = recordableLayer
    self.queue = queue
  }

  func produce(handler: @escaping (CVPixelBuffer) -> Void) throws {
    guard let texture = recordableLayer.lastTexture else { throw Error.noTexture }

    if #available(iOS 14, *) { try produceUsingSurface(from: texture, handler: handler) }
    else { try produceUsingBytes(from: texture, handler: handler) }
  }

  @available(iOS 14, *)
  private func produceUsingSurface(
    from texture: MTLTexture,
    handler: @escaping (CVPixelBuffer) -> Void
  ) throws {
    guard let surface = texture.iosurface else { throw Error.noSurface }
    let surfacePixelBuffer = try PixelBuffer(surface)
    queue.async { handler(surfacePixelBuffer.cvPxelBuffer) }
  }

  private func produceUsingBytes(
    from texture: MTLTexture,
    handler: @escaping (CVPixelBuffer) -> Void
  ) throws {
    guard !texture.isFramebufferOnly else { throw Error.framebufferOnly }

    let width = Int(recordableLayer.drawableSize.width)
    let height = Int(recordableLayer.drawableSize.height)

    let pixelBufferPool = try pixelBufferPoolFactory.getPixelBufferPool(
      width: width,
      height: height,
      pixelFormat: recordableLayer.pixelFormat.pixelFormatType
    )

    let pixelBuffer = try pixelBufferPool.getPixelBuffer()

    if let iccData = recordableLayer.pixelFormat.iccData {
      pixelBuffer.propagatedAttachments = [kCVImageBufferICCProfileKey as String: iccData]
    }

    let bytesPerRow = pixelBuffer.bytesPerRow
    try pixelBuffer.locked { (pb) in
      guard let baseAddress = pixelBuffer.baseAddress else { throw Error.baseAddress }

      texture.getBytes(
        baseAddress,
        bytesPerRow: bytesPerRow,
        from: MTLRegionMake2D(0, 0, width, height),
        mipmapLevel: 0
      )

      guard !isEmpty(baseAddress, size: bytesPerRow * height) else { throw Error.noBytes }
    }

    queue.async { handler(pixelBuffer.cvPxelBuffer) }
  }

  func isEmpty(_ buffer: UnsafeMutableRawPointer, size: Int) -> Bool {
    if emptyBuffer.size != size { emptyBuffer = Buffer.zeroed(size: size) }
    return memcmp(buffer, emptyBuffer.ptr, size) == 0
  }
}
