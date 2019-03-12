//
//  SCNRecordableView.swift
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
import SceneKit

open class SCNRecordableView: SceneKit.SCNView {
    
    #if !targetEnvironment(simulator)
    override open class var layerClass: AnyClass {
        guard super.layerClass is CAMetalLayer.Type else {
            return super.layerClass
        }
        return CAMetalRecorderLayer.self
    }
    
    var metalLayer: CAMetalRecorderLayer? {
        switch renderingAPI {
        case .metal:
            assert(layer is CAMetalRecorderLayer, "SCNRecorder.SCNView layer must be SCNRecorder.CAMetalRecorderLayer or its descendant")
            return (layer as! CAMetalRecorderLayer)
        case .openGLES2:
            return nil
        }
    }
    
    var lastDrawable: CAMetalDrawable? {
        return metalLayer?.lastDrawable
    }
    #endif
    
    weak var recorder: SCNRecorder? {
        didSet {
            if let oldRecorder = oldValue {
                super.delegate = oldRecorder.sceneViewDelegate
            }
            
            guard let recorder = recorder else {
                return
            }
            
            recorder.sceneViewDelegate = super.delegate
            super.delegate = recorder
        }
    }
    
    open override weak var delegate: SCNSceneRendererDelegate? {
        get {
            return super.delegate
        }
        set {
            guard let recorder = recorder else {
                super.delegate = newValue
                return
            }
            recorder.sceneViewDelegate = newValue
        }
    }
}
