//
//  PixelBuffer.swift
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

final class PixelBuffer: CustomStringConvertible {

  struct Attributes: Hashable {

    var width: Int

    var height: Int

    var pixelFormat: OSType

    var cfDictionary: CFDictionary {
      [
        kCVPixelBufferWidthKey: width,
        kCVPixelBufferHeightKey: height,
        kCVPixelBufferPixelFormatTypeKey: pixelFormat,
        kCVPixelBufferIOSurfacePropertiesKey: [:],
        kCVPixelBufferMetalCompatibilityKey: true
      ] as CFDictionary
    }

    init(
      width: Int,
      height: Int,
      pixelFormat: OSType
    ) {
      self.width = width
      self.height = height
      self.pixelFormat = pixelFormat
    }

    init(_ attributes: MetalTexture.Attributes) {
      width = attributes.width
      height = attributes.height
      pixelFormat = attributes.pixelFormat.pixelFormatType
    }
  }

  enum Error: Swift.Error {
    case allocation(errorCode: CVReturn)
    case lockBaseAddress(errorCode: CVReturn)
    case unlockBaseAddress(errorCode: CVReturn)
  }

  let cvPxelBuffer: CVPixelBuffer

  var baseAddress: UnsafeMutableRawPointer? { CVPixelBufferGetBaseAddress(cvPxelBuffer) }

  var bytesPerRow: Int { CVPixelBufferGetBytesPerRow(cvPxelBuffer) }

  var width: Int { CVPixelBufferGetWidth(cvPxelBuffer) }

  var height: Int { CVPixelBufferGetHeight(cvPxelBuffer) }

  var bytesCount: Int { bytesPerRow * height }

  var pixelFormat: OSType { CVPixelBufferGetPixelFormatType(cvPxelBuffer) }

  var propagatedAttachments: [String: Any]? {
    get { CVBufferGetAttachments(cvPxelBuffer, .shouldPropagate) as? [String: Any] }
    set {
      guard let attachments = newValue else { return }
      CVBufferSetAttachments(cvPxelBuffer, attachments as CFDictionary, .shouldPropagate)
    }
  }

  var nonPropagatedAttachments: [String: Any]? {
    get { CVBufferGetAttachments(cvPxelBuffer, .shouldNotPropagate) as? [String: Any] }
    set {
      guard let attachments = newValue else { return }
      CVBufferSetAttachments(cvPxelBuffer, attachments as CFDictionary, .shouldNotPropagate)
    }
  }

  var description: String { "\(cvPxelBuffer)" }

  init(_ cvPxelBuffer: CVPixelBuffer) { self.cvPxelBuffer = cvPxelBuffer }

  convenience init(_ surface: IOSurface) throws {
    var unmanagedPixelBuffer: Unmanaged<CVPixelBuffer>?

    let errorCode = CVPixelBufferCreateWithIOSurface(
      nil,
      surface,
      nil,
      &unmanagedPixelBuffer
    )

    guard errorCode == kCVReturnSuccess,
          let pixelBuffer = unmanagedPixelBuffer?.takeRetainedValue()
    else { throw Error.allocation(errorCode: errorCode) }

    self.init(pixelBuffer)
  }

  @discardableResult
  func locked(
    readOnly: Bool = false,
    handler: (PixelBuffer) throws -> Void
  ) throws -> PixelBuffer {
    try lock(readOnly: readOnly)
    defer { try? unlock(readOnly: readOnly) }
    try handler(self)
    return self
  }

  func lock(readOnly: Bool = false) throws {
    let errorCode = CVPixelBufferLockBaseAddress(cvPxelBuffer, readOnly ? [.readOnly] : [])
    guard errorCode == kCVReturnSuccess else { throw Error.lockBaseAddress(errorCode: errorCode) }
  }

  func unlock(readOnly: Bool = false) throws {
    let errorCode = CVPixelBufferUnlockBaseAddress(cvPxelBuffer, readOnly ? [.readOnly] : [])
    guard errorCode == kCVReturnSuccess else { throw Error.unlockBaseAddress(errorCode: errorCode) }
  }

  func copyFrom(_ pixelBuffer: CVPixelBuffer) throws { try copyFrom(PixelBuffer(pixelBuffer)) }

  func copyFrom(_ pixelBuffer: PixelBuffer) throws {
    try pixelBuffer.locked { (pixelBuffer) in
      try locked { (this) in
        memcpy(this.baseAddress, pixelBuffer.baseAddress, this.bytesCount)
        this.propagatedAttachments = pixelBuffer.propagatedAttachments
      }
    }
  }
}
