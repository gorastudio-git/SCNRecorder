//
//  PixelBufferPool.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 26.11.2020.
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

final class PixelBufferPool {

  enum Error: Swift.Error {
    case pixelBufferPoolAllocation(errorCode: CVReturn)

    case allocationTresholdExceeded
    case pixelBufferAllocation(errorCode: CVReturn)
  }

  let pixelBufferPool: CVPixelBufferPool

  var allocationTreshold: UInt = 0

  init(_ pixelBufferPool: CVPixelBufferPool) { self.pixelBufferPool = pixelBufferPool }

  convenience init(attributes: PixelBuffer.Attributes) throws {
    var unmanagedPixelBufferPool: CVPixelBufferPool?
    let errorCode = CVPixelBufferPoolCreate(
      nil,
      nil,
      attributes.cfDictionary,
      &unmanagedPixelBufferPool
    )

    guard errorCode == kCVReturnSuccess,
          let pixelBufferPool = unmanagedPixelBufferPool
    else { throw Error.pixelBufferPoolAllocation(errorCode: errorCode) }

    self.init(pixelBufferPool)
  }

  func getPixelBuffer(
    propagatedAttachments: [String: Any]? = nil,
    nonPropagatedAttachments: [String: Any]? = nil
  ) throws -> PixelBuffer {
    var unmanagedPixelBuffer: CVPixelBuffer?

    let errorCode = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(
      nil,
      pixelBufferPool,
      allocationTreshold == 0
        ? nil
        : [kCVPixelBufferPoolAllocationThresholdKey: allocationTreshold] as CFDictionary,
      &unmanagedPixelBuffer
    )

    switch (errorCode, unmanagedPixelBuffer) {
    case (kCVReturnSuccess, .some(let cvPixelBuffer)):
      let pixelBuffer = PixelBuffer(cvPixelBuffer)
      pixelBuffer.propagatedAttachments = propagatedAttachments
      pixelBuffer.nonPropagatedAttachments = nonPropagatedAttachments
      return pixelBuffer
    case (kCVReturnWouldExceedAllocationThreshold, _):
      throw Error.allocationTresholdExceeded
    default:
      throw Error.pixelBufferAllocation(errorCode: errorCode)
    }
  }
}
