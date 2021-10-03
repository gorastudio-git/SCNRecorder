//
//  SCNView+MulticastDelegate.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
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
import ARKit
import MulticastDelegate

private var multicastDelegateKey: UInt8 = 0

extension SCNView {

  final class MulticastDelegate: OriginMulticastDelegate<SCNSceneRendererDelegate>, SCNSceneRendererDelegate { }

  static let swizzleSetDelegateImplementation: Void = {
    let aClass: AnyClass = SCNView.self

    guard let originalMethod = class_getInstanceMethod(aClass, #selector(setter: delegate)),
          let swizzledMethod = class_getInstanceMethod(aClass, #selector(swizzled_setDelegate))
    else { return }

    method_exchangeImplementations(originalMethod, swizzledMethod)
  }()

  static func swizzle() { _ = swizzleSetDelegateImplementation }

  var multicastDelegateStorage: AssociatedStorage<MulticastDelegate> {
    AssociatedStorage(object: self, key: &multicastDelegateKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }

  var multicastDelegate: MulticastDelegate {
    if let multicastDelegate = multicastDelegateStorage.get() { return multicastDelegate }
    let multicastDelegate = MulticastDelegate()
    multicastDelegateStorage.set(multicastDelegate)
    multicastDelegate.origin = delegate
    delegate = multicastDelegate
    return multicastDelegate
  }

  func swizzle() { Self.swizzle() }

  func addDelegate(_ delegate: SCNSceneRendererDelegate) {
    multicastDelegate.addDelegate(delegate)
    self.delegate = multicastDelegate
  }

  func removeDelegate(_ delegate: SCNSceneRendererDelegate) {
    multicastDelegate.removeDelegate(delegate)
    self.delegate = multicastDelegate
  }

  @objc dynamic func swizzled_setDelegate(_ delegate: SCNSceneRendererDelegate) {
    if delegate is MulticastDelegate {
      swizzled_setDelegate(delegate)
      return
    }
    multicastDelegate.origin = delegate
    swizzled_setDelegate(multicastDelegate)
  }
}
