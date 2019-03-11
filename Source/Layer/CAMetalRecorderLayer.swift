//
//  CAMetalRecorderLayer.swift
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
import UIKit

#if !targetEnvironment(simulator)

open class CAMetalRecorderLayer: UIKit.CAMetalLayer {
    
    var lastFramebufferOnly: Bool = true
    
    open override var framebufferOnly: Bool {
        get {
            return super.framebufferOnly
        }
        set {
            if recording {
                lastFramebufferOnly = newValue
            }
            else {
                super.framebufferOnly = newValue
            }
        }
    }
    
    var recording: Bool = false
    
    open var lastDrawable: CAMetalDrawable?
    
    open override func nextDrawable() -> CAMetalDrawable? {
        lastDrawable = super.nextDrawable()
        return lastDrawable
    }
    
    func startRecording() {
        guard !recording else { return }
        lastFramebufferOnly = framebufferOnly
        framebufferOnly = false
        recording = true
    }
    
    func stopRecording() {
        guard recording else { return }
        recording = false
        framebufferOnly = lastFramebufferOnly
    }
}

#endif
