//
//  CAMetalLayer+RecordableLayer.swift
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
import UIKit
import AVFoundation

private var lastTextureKey: UInt8 = 0

#if !targetEnvironment(simulator)

extension CAMetalLayer {

  var lastTextureStorage: AssociatedStorage<MTLTexture> {
    AssociatedStorage(object: self, key: &lastTextureKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }
}

extension CAMetalLayer: RecordableLayer {

  static let swizzleNextDrawableImplementation: Void = {
      let aClass: AnyClass = CAMetalLayer.self

      guard let originalMethod = class_getInstanceMethod(aClass, #selector(nextDrawable)),
            let swizzledMethod = class_getInstanceMethod(aClass, #selector(swizzled_nextDrawable))
      else { return }

      method_exchangeImplementations(originalMethod, swizzledMethod)
  }()

  static func swizzle() {
    _ = swizzleNextDrawableImplementation
  }

  public var lastTexture: MTLTexture? {
    get { lastTextureStorage.get() }
    set { lastTextureStorage.set(newValue) }
  }

  @objc dynamic func swizzled_nextDrawable() -> CAMetalDrawable? {
    let nextDrawable = swizzled_nextDrawable()
    lastTexture = nextDrawable?.texture
    return nextDrawable
  }
}

#else // IF targetEnvironment(simulator)

@available(iOS 13.0, *)
extension CAMetalLayer {

  var lastTextureStorage: AssociatedStorage<MTLTexture> {
    AssociatedStorage(object: self, key: &lastTextureKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }
}

@available(iOS 13.0, *)
extension CAMetalLayer: RecordableLayer {

  static let swizzleNextDrawableImplementation: Void = {
      let aClass: AnyClass = CAMetalLayer.self

      guard let originalMethod = class_getInstanceMethod(aClass, #selector(nextDrawable)),
            let swizzledMethod = class_getInstanceMethod(aClass, #selector(swizzled_nextDrawable))
      else { return }

      method_exchangeImplementations(originalMethod, swizzledMethod)
  }()

  static func swizzle() {
    _ = swizzleNextDrawableImplementation
  }

  public var lastTexture: MTLTexture? {
    get { lastTextureStorage.get() }
    set { lastTextureStorage.set(newValue) }
  }

  @objc dynamic func swizzled_nextDrawable() -> CAMetalDrawable? {
    let nextDrawable = swizzled_nextDrawable()
    lastTexture = nextDrawable?.texture
    return nextDrawable
  }
}

#endif // END !targetEnvironment(simulator)
