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

#if !targetEnvironment(simulator)

extension MetalPixelBufferProducer {
  enum MetalError: Swift.Error {
    case lastDrawable
    case framebufferOnly
  }
}

final class MetalPixelBufferProducer: PixelBufferProducer {

  var size: CGSize { recordableLayer.drawableSize }
  
  var videoColorProperties: [String: String]? { recordableLayer.pixelFormat.videoColorProperties }
  
  var recommendedPixelBufferAttributes: [String: Any] {
    var attributes: [String: Any] = [
      kCVPixelBufferWidthKey as String: Int(recordableLayer.drawableSize.width),
      kCVPixelBufferHeightKey as String: Int(recordableLayer.drawableSize.height),
      kCVPixelBufferPixelFormatTypeKey as String: recordableLayer.pixelFormat.pixelFormatType,
      kCVPixelBufferIOSurfacePropertiesKey as String: [:]
    ]

    if let iccData = recordableLayer.pixelFormat.iccData {
      attributes[kCVBufferPropagatedAttachmentsKey as String] = [
        kCVImageBufferICCProfileKey: iccData
      ]
    }

    return attributes
  }

  var emptyBuffer = Buffer.zeroed(size: 0)

  let recordableLayer: SceneRecordableLayer

  let context: CIContext

  init(recordableLayer: SceneRecordableLayer) {
    self.recordableLayer = recordableLayer
    self.context = CIContext(mtlDevice: recordableLayer.device ?? MTLCreateSystemDefaultDevice()!)
  }

  func startWriting() {
    guard Thread.isMainThread else { return DispatchQueue.main.sync(execute: startWriting) }
    recordableLayer.onStartRecording()
  }

  func writeIn(pixelBuffer: inout CVPixelBuffer) throws {

    guard let lastDrawable = recordableLayer.lastDrawable else { throw MetalError.lastDrawable }

    let texture = lastDrawable.texture
    guard !texture.isFramebufferOnly else { throw MetalError.framebufferOnly }

    try pixelBuffer.locked { (pixelBuffer) in
      guard let baseAddress = pixelBuffer.baseAddress else { throw Error.getBaseAddress }

      let bytesPerRow = pixelBuffer.bytesPerRow
      let height = pixelBuffer.height
      let width = pixelBuffer.width

      guard texture.width == width, texture.height == height else { throw Error.wrongSize }

      texture.getBytes(
        baseAddress,
        bytesPerRow: bytesPerRow,
        from: MTLRegionMake2D(0, 0, width, height),
        mipmapLevel: 0
      )

      guard !isEmpty(baseAddress, size: bytesPerRow * height) else {
        throw PixelBufferProducer.Error.emptySource
      }
    }
  }

  func stopWriting() {
    guard Thread.isMainThread else { return DispatchQueue.main.sync(execute: stopWriting) }
    recordableLayer.onStopRecording()
  }

  func isEmpty(_ buffer: UnsafeMutableRawPointer, size: Int) -> Bool {
    if emptyBuffer.size != size { emptyBuffer = Buffer.zeroed(size: size) }
    return memcmp(buffer, emptyBuffer.ptr, size) == 0
  }
}

#endif
