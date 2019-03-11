//
//  EAGLPixelBufferProducer.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 11/03/2019.
//  Copyright (c) 2019 GORA Studio. https://gora.studio
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
    
    enum Error: Swift.Error {
        
        case setCurrentContext
        
        case framebufferStatusOES(status: GLenum)
    }
}

final class EAGLPixelBufferProducer: PixelBufferProducer {
    
    lazy var recommendedVideoSettings: [String : Any] = {
        let size = getSize()
        return [
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height,
            AVVideoCodecKey: AVVideoCodecType.h264
        ]
    }()
    
    lazy var recommendedPixelBufferAttributes: [String : Any] = {
        let size = getSize()
        return [
            kCVPixelBufferWidthKey as String: size.width,
            kCVPixelBufferHeightKey as String: size.height,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32RGBA,
            kCVPixelBufferBytesPerRowAlignmentKey as String: 4,
        ]
    }()
    
    let eaglContext: EAGLContext
    
    lazy var context: CIContext = {
        return CIContext(eaglContext: EAGLContext(api: eaglContext.api)!)
    }()
    
    init(eaglContext: EAGLContext) {
        self.eaglContext = eaglContext
    }
    
    func writeIn(pixelBuffer: inout CVPixelBuffer) throws {
        
        var errorCode = CVPixelBufferLockBaseAddress(pixelBuffer, [])
        guard errorCode == kCVReturnSuccess else {
            throw PixelBufferProducer.Error.lockBaseAddress(errorCode: errorCode)
        }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw PixelBufferProducer.Error.getBaseAddress
        }
        
        let status = glCheckFramebufferStatusOES(GLenum(GL_FRAMEBUFFER_OES))
        guard status == GL_FRAMEBUFFER_COMPLETE_OES else {
            throw Error.framebufferStatusOES(status: status)
        }
        
        glPixelStorei(GLenum(GL_PACK_ALIGNMENT),
                      4)
        
        glReadPixels(0,
                     0,
                     GLsizei(CVPixelBufferGetWidth(pixelBuffer)),
                     GLsizei(CVPixelBufferGetHeight(pixelBuffer)),
                     GLenum(GL_RGBA),
                     GLenum(GL_UNSIGNED_BYTE),
                     baseAddress)
        
        errorCode = CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        guard errorCode == kCVReturnSuccess else {
            throw PixelBufferProducer.Error.unlockBaseAddress(errorCode: errorCode)
        }
    }
}

// MARK: - Private helpers
private extension EAGLPixelBufferProducer {
    
    static func setCurrentContext(_ context: EAGLContext) throws -> () -> Void {
        let currentContext = EAGLContext.current()
        
        guard currentContext != context else {
            return { }
        }
        
        guard EAGLContext.setCurrent(context) else {
            throw Error.setCurrentContext
        }
        
        return {
            EAGLContext.setCurrent(currentContext)
        }
    }
    
    func getSize() -> (width: Int, height: Int) {
        let rollback = try? EAGLPixelBufferProducer.setCurrentContext(eaglContext)
        
        defer {
            rollback?()
        }
        
        var glWidth: GLint = 0
        var glHeight: GLint = 0
        
        glGetRenderbufferParameterivOES(GLenum(GL_RENDERBUFFER_OES), GLenum(GL_RENDERBUFFER_WIDTH_OES), &glWidth)
        glGetRenderbufferParameterivOES(GLenum(GL_RENDERBUFFER_OES), GLenum(GL_RENDERBUFFER_HEIGHT_OES), &glHeight)
        
        return (Int(glWidth), Int(glHeight))
    }
}
