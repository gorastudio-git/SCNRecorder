//
//  SCNView+SceneRecordableView.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 30.12.2019.
//  Copyright © 2020 GORA Studio. All rights reserved.
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

#if !DO_NOT_SWIZZLE

private var sceneRecorderKey: UInt8 = 0

extension SCNView: SceneRecordableView {

  static let swizzleSetDelegateImplementation: Void = {
    let aClass: AnyClass = SCNView.self

    guard let originalMethod = class_getInstanceMethod(aClass, #selector(setter: delegate)),
          let swizzledMethod = class_getInstanceMethod(aClass, #selector(swizzled_setDelegate))
    else { return }

    method_exchangeImplementations(originalMethod, swizzledMethod)
  }()

  static func swizzle() { _ = swizzleSetDelegateImplementation }

  public var sceneRecorder: SceneRecorder? {
    get { objc_getAssociatedObject(self, &sceneRecorderKey) as? SceneRecorder }
    set {
      let oldRecorder = sceneRecorder
      objc_setAssociatedObject(self, &sceneRecorderKey, nil, .OBJC_ASSOCIATION_RETAIN)
      if delegate === oldRecorder { delegate = oldRecorder?.sceneViewDelegate }

      guard let recorder = newValue else { return }
      recorder.sceneViewDelegate = delegate
      delegate = recorder
      objc_setAssociatedObject(self, &sceneRecorderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }
  
  @objc dynamic func swizzled_setDelegate(_ delegate: SCNSceneRendererDelegate) {
    if let baseRecorder = delegate as? BaseRecorder {
        if let sceneRecorder = self.sceneRecorder {
            baseRecorder.delegate = sceneRecorder.delegate
            sceneRecorder.delegate = baseRecorder
        }
        else {
            baseRecorder.delegate = self.delegate
            swizzled_setDelegate(delegate)
        }
    }
    else if let sceneRecorder = sceneRecorder {
        sceneRecorder.delegate = delegate
    }
    else {
        swizzled_setDelegate(delegate)
    }
  }
}

#endif // !DO_NOT_SWIZZLE
