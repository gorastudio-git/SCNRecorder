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

#if !targetEnvironment(simulator)

private var lastIOSurfaceKey: UInt8 = 0

extension CAMetalLayer {

  var lastIOSurfaceStorage: AssociatedStorage<IOSurface> {
    AssociatedStorage(object: self, key: &lastIOSurfaceKey, policy: .OBJC_ASSOCIATION_RETAIN)
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

  public var lastIOSurface: IOSurface? {
    get { lastIOSurfaceStorage.get() }
    set { lastIOSurfaceStorage.set(newValue) }
  }

  func swizzle() { Self.swizzle() }

  @objc dynamic func swizzled_nextDrawable() -> CAMetalDrawable? {
    let nextDrawable = swizzled_nextDrawable()
    lastIOSurface = nextDrawable?.texture.iosurface
    return nextDrawable
  }
}

#endif // !targetEnvironment(simulator)
