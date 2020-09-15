//
//  EAGLPixelBufferProducer.swift
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

extension EAGLPixelBufferProducer {
  enum EAGLError: Swift.Error {
    case setCurrentContext
    case framebufferStatusOES(status: GLenum)
  }
}

final class EAGLPixelBufferProducer: PixelBufferProducer {

  static let alignment = 4

  var size: CGSize {
    let rollback = try? EAGLPixelBufferProducer.setCurrentContext(eaglContext)
    defer { rollback?() }

    var glWidth: GLint = 0
    var glHeight: GLint = 0

    glGetRenderbufferParameterivOES(
      GLenum(GL_RENDERBUFFER_OES),
      GLenum(GL_RENDERBUFFER_WIDTH_OES),
      &glWidth
    )
    glGetRenderbufferParameterivOES(
      GLenum(GL_RENDERBUFFER_OES),
      GLenum(GL_RENDERBUFFER_HEIGHT_OES),
      &glHeight
    )

    return CGSize(width: CGFloat(glWidth), height: CGFloat(glHeight))
  }

  var videoColorProperties: [String: String]? { nil }

  var recommendedPixelBufferAttributes: [String: Any] {
    let size = self.size
    var attributes: [String: Any] = [
      kCVPixelBufferWidthKey as String: Int(size.width),
      kCVPixelBufferHeightKey as String: Int(size.height),
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
      kCVPixelBufferBytesPerRowAlignmentKey as String: 4
    ]

    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
    if let iccData = colorSpace.copyICCData() {
      attributes[kCVBufferPropagatedAttachmentsKey as String] = [
        kCVImageBufferICCProfileKey: iccData
      ]
    }
    return attributes
  }

  var buffer = Buffer(size: 0, alignment: EAGLPixelBufferProducer.alignment)

  let eaglContext: EAGLContext

  lazy var context: CIContext = {
    CIContext(
      eaglContext: EAGLContext(api: eaglContext.api) ?? EAGLContext(api: .openGLES3)!
    )
  }()

  init(eaglContext: EAGLContext) { self.eaglContext = eaglContext }

  func writeIn(pixelBuffer: inout CVPixelBuffer) throws {
    try pixelBuffer.locked { (pixelBuffer) in
      guard let baseAddress = pixelBuffer.baseAddress else { throw Error.getBaseAddress }

      let status = glCheckFramebufferStatusOES(GLenum(GL_FRAMEBUFFER_OES))
      guard status == GL_FRAMEBUFFER_COMPLETE_OES else {
        throw EAGLError.framebufferStatusOES(status: status)
      }

      let alignment = EAGLPixelBufferProducer.alignment
      let buffer = getBuffer(size: pixelBuffer.bytesCount, alignment: alignment)

      glPixelStorei(
        GLenum(GL_PACK_ALIGNMENT),
        GLint(alignment)
      )

      glReadPixels(
        0,
        0,
        GLsizei(pixelBuffer.width),
        GLsizei(pixelBuffer.height),
        GLenum(GL_BGRA),
        GLenum(GL_UNSIGNED_BYTE),
        buffer.ptr
      )

      let bytesPerRow = pixelBuffer.bytesPerRow
      for row in 0..<pixelBuffer.height {
        memcpy(
          baseAddress.advanced(by: row * bytesPerRow),
          buffer.ptr .advanced(by: (pixelBuffer.height - row - 1) * bytesPerRow),
          bytesPerRow
        )
      }
    }
  }
}

// MARK: - Private helpers
private extension EAGLPixelBufferProducer {

  static func setCurrentContext(_ context: EAGLContext) throws -> () -> Void {
    let currentContext = EAGLContext.current()
    guard currentContext != context else { return { } }
    guard EAGLContext.setCurrent(context) else { throw EAGLError.setCurrentContext }
    return { EAGLContext.setCurrent(currentContext) }
  }

  func getBuffer(size: Int, alignment: Int) -> Buffer {
    if buffer.size != size { buffer = Buffer(size: size, alignment: alignment) }
    return buffer
  }
}
