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

    case framebufferOnly
  }

  var size: CGSize { recordableLayer.drawableSize }

  var videoColorProperties: [String: String]? { recordableLayer.pixelFormat.videoColorProperties }

  let recordableLayer: RecordableLayer

  let queue: DispatchQueue

  lazy var pixelBufferPoolFactory = PixelBufferPoolFactory.getWeaklyShared()

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

    let pixelBufferPool = try pixelBufferPoolFactory.getPixelBufferPool(
      width: texture.width,
      height: texture.height,
      pixelFormat: texture.pixelFormat.pixelFormatType
    )

    let pixelBuffer = try pixelBufferPool.getPixelBuffer()
    try pixelBuffer.locked { (pb) in
      texture.getBytes(
        pb.baseAddress!,
        bytesPerRow: pixelBuffer.bytesPerRow,
        from: MTLRegionMake2D(0, 0, texture.width, texture.height),
        mipmapLevel: 0
      )
    }

    queue.async { handler(pixelBuffer.cvPxelBuffer) }
  }
}
