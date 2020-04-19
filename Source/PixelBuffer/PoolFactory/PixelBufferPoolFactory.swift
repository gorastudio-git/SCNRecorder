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

  let pixelBufferPools = Atomic([String: CVPixelBufferPool]())

  func makeWithAttributes(
    _ attributes: [String: Any]
  ) throws -> CVPixelBufferPool {
    let key = makeKeyWithAttributes(attributes)
    return try pixelBufferPools.modify {
      if let pixelBufferPool = $0[key] { return pixelBufferPool }
      let pixelBufferPool = try CVPixelBufferPool.makeWithAttributes(attributes)
      $0[key] = pixelBufferPool
      return pixelBufferPool
    }
  }

  func makeKeyWithAttributes(
    _ attributes: [String: Any]
  ) -> String {
    return """
      Width: \(String(describing: attributes[kCVPixelBufferWidthKey as String])),
      Height: \(String(describing: attributes[kCVPixelBufferHeightKey as String])),
      PixelFormatType: \(String(describing: attributes[kCVPixelBufferPixelFormatTypeKey as String]))
    """
  }
}
