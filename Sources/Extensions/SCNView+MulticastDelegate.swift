//
//  SCNView+MulticastDelegate.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

import Foundation
import SceneKit
import ARKit
import SCNRecorder.Private

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
