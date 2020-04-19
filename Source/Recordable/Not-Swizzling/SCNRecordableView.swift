//
//  SCNRecordableView.swift
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
import SceneKit

#if DO_NOT_SWIZZLE

open class SCNRecordableView: SCNView, RecordableView {

  #if !targetEnvironment(simulator)
  override open class var layerClass: AnyClass {
    guard super.layerClass is CAMetalLayer.Type else { return super.layerClass }
    return CAMetalRecordableLayer.self
  }
  #endif // !targetEnvironment(simulator)

  open override weak var delegate: SCNSceneRendererDelegate? {
    get { super.delegate }
    set {
      guard let recorder = recorder else {
        super.delegate = newValue
        return
      }
      recorder.sceneViewDelegate = newValue
    }
  }
}

#else // DO_NOT_SWIZZLE

@available(*, deprecated, message: "With swizzling you don't have to use SCNRecordableView")
open class SCNRecordableView: SCNView { }

#endif // DO_NOT_SWIZZLE
