//
//  CVPixelBuffer+Helpers.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 30.12.2019.
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

extension CVPixelBuffer {

  enum Error: Swift.Error {
    case creation(errorCode: CVReturn)
    case lockBaseAddress(errorCode: CVReturn)
    case unlockBaseAddress(errorCode: CVReturn)
  }

  var baseAddress: UnsafeMutableRawPointer? { CVPixelBufferGetBaseAddress(self) }

  var bytesPerRow: Int { CVPixelBufferGetBytesPerRow(self) }

  var width: Int { CVPixelBufferGetWidth(self) }

  var height: Int { CVPixelBufferGetHeight(self) }

  var bytesCount: Int { bytesPerRow * height }

  static func makeWithPixelBufferPool(_ pixelBufferPool: CVPixelBufferPool) throws -> CVPixelBuffer {
    var unmanagedPixelBuffer: CVPixelBuffer?
    let errorCode = CVPixelBufferPoolCreatePixelBuffer(
      nil,
      pixelBufferPool,
      &unmanagedPixelBuffer
    )
    guard errorCode == kCVReturnSuccess,
          let pixelBuffer = unmanagedPixelBuffer
    else { throw Error.creation(errorCode: errorCode) }
    return pixelBuffer
  }

  @discardableResult
  func locked(
    readOnly: Bool = false,
    handler: (CVPixelBuffer) throws -> Void
  ) throws -> CVPixelBuffer {
    try lock(readOnly: readOnly)
    defer { try? unlock(readOnly: readOnly) }
    try handler(self)
    return self
  }

  func lock(readOnly: Bool = false) throws {
    let errorCode = CVPixelBufferLockBaseAddress(self, readOnly ? [.readOnly] : [])
    guard errorCode == kCVReturnSuccess else { throw Error.lockBaseAddress(errorCode: errorCode) }
  }

  func unlock(readOnly: Bool = false) throws {
    let errorCode = CVPixelBufferUnlockBaseAddress(self, readOnly ? [.readOnly] : [])
    guard errorCode == kCVReturnSuccess else { throw Error.unlockBaseAddress(errorCode: errorCode) }
  }

  func applyFilters(_ filters: [Filter], using context: CIContext) throws {
    guard !filters.isEmpty else { return }

    var image = CIImage(cvPixelBuffer: self)
    for filter in filters {
      let ciFilter = try filter.makeCIFilter(for: image)
      guard let outputImage = ciFilter.outputImage else { throw Filter.Error.noOutput }
      image = outputImage
    }

    context.render(image, to: self)
  }

  func copyWithPixelBufferPool(_ pixelBufferPool: CVPixelBufferPool) throws -> CVPixelBuffer {
    let copyPixelBuffer = try CVPixelBuffer.makeWithPixelBufferPool(pixelBufferPool)

    try locked(readOnly: true) { (pixelBuffer) in
      try copyPixelBuffer.locked { (copyPixelBuffer) in
        memcpy(copyPixelBuffer.baseAddress, pixelBuffer.baseAddress, pixelBuffer.bytesCount)
      }
    }

    return copyPixelBuffer
  }
}
