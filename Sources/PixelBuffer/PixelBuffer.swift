//
//  PixelBuffer.swift
//  SCNRecorder
//
//  Created by VG on 26.11.2020.
//

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
        kCVPixelBufferIOSurfacePropertiesKey as String: [:]
      ].compactMapValues({ $0 }) as CFDictionary
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
          let pixelBuffer = unmanagedPixelBuffer?.takeUnretainedValue()
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
