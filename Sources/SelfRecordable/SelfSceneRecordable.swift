//
//  SelfSceneRecordable.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 25.05.2020.
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
import UIKit
import SceneKit

private var sceneRecorderKey: UInt8 = 0

public protocol SelfSceneRecordable: SelfRecordable {

  var sceneRecorder: SceneRecorder? { get set }
}

extension SelfSceneRecordable {

  public var recorder: (BaseRecorder & Renderable)? { sceneRecorder }
}

extension SelfSceneRecordable {

  var sceneRecorderStorage: AssociatedStorage<SceneRecorder> {
    AssociatedStorage(object: self, key: &sceneRecorderKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }

  public var sceneRecorder: SceneRecorder? {
    get { sceneRecorderStorage.get() }
    set { sceneRecorderStorage.set(newValue) }
  }
}

extension SelfSceneRecordable where Self: MetalRecordable {

  public func injectRecorder() {
    assert(sceneRecorder == nil)

    do { sceneRecorder = try SceneRecorder(self) }
    catch { assertionFailure("\(error)") }
  }
}
