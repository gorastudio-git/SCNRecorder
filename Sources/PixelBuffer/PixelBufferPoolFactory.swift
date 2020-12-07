//
//  PixelBufferPoolFactory.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 29.12.2019.
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

final class PixelBufferPoolFactory {

  private static let weaklySharedAllocationTreshold: UInt = 10

  private static weak var shared: PixelBufferPoolFactory?

  static func getWeaklyShared() -> PixelBufferPoolFactory {
    if let shared = shared { return shared }

    let pixelBufferPoolFactory = PixelBufferPoolFactory(
      allocationTreshold: weaklySharedAllocationTreshold
    )
    shared = pixelBufferPoolFactory
    return pixelBufferPoolFactory
  }

  var pixelBufferPools = [PixelBuffer.Attributes: PixelBufferPool]()

  let allocationTreshold: UInt

  init(allocationTreshold: UInt) { self.allocationTreshold = allocationTreshold }

  func getPixelBufferPool(for pixelBuffer: CVPixelBuffer) throws -> PixelBufferPool {
    try getPixelBufferPool(for: PixelBuffer(pixelBuffer))
  }

  func getPixelBufferPool(for pixelBuffer: PixelBuffer) throws -> PixelBufferPool {
    try getPixelBufferPool(
      width: pixelBuffer.width,
      height: pixelBuffer.height,
      pixelFormat: pixelBuffer.pixelFormat
    )
  }

  func getPixelBufferPool(
    width: Int,
    height: Int,
    pixelFormat: OSType
  ) throws -> PixelBufferPool {
    try getPixelBufferPool(
      attributes: PixelBuffer.Attributes(
        width: width,
        height: height,
        pixelFormat: pixelFormat
      )
    )
  }

  func getPixelBufferPool(attributes: PixelBuffer.Attributes) throws -> PixelBufferPool {
    if let pixelBufferPool = pixelBufferPools[attributes] { return pixelBufferPool }

    let pixelBufferPool = try PixelBufferPool(attributes: attributes)
    pixelBufferPool.allocationTreshold = allocationTreshold
    pixelBufferPools[attributes] = pixelBufferPool
    return pixelBufferPool
  }
}
