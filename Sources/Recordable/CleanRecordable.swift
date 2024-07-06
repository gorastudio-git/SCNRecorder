//
//  CleanRecordable.swift
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
import SceneKit

private var cleanKey: UInt8 = 0

public protocol CleanRecordable: AnyObject {

  var cleanPixelBuffer: CVPixelBuffer? { get }
}

public extension CleanRecordable {

  internal var cleanStorage: AssociatedStorage<Clean<Self>> {
    AssociatedStorage(object: self, key: &cleanKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }

  var clean: SelfRecordable {
    cleanStorage.get() ?? {
      let clean = Clean(cleanRecordable: self)
      cleanStorage.set(clean)
      return clean
    }()
  }
}

final class Clean<T: CleanRecordable>: SelfRecordable {

  public var recorder: (BaseRecorder & Renderable)? { cleanRecorder }

  var cleanRecorder: CleanRecorder<T>?

  var videoRecording: VideoRecording?

  weak var cleanRecordable: T?

  init(cleanRecordable: T) {
    self.cleanRecordable = cleanRecordable
  }

  func injectRecorder() {
    assert(cleanRecorder == nil)
    assert(cleanRecordable != nil)

    cleanRecorder = cleanRecordable.map { CleanRecorder($0) }
  }

  func prepareForRecording() {
    (cleanRecordable as? SCNView)?.swizzle()
    guard cleanRecorder == nil else { return }

    injectRecorder()
    assert(cleanRecorder != nil)
    (cleanRecordable as? SCNView)?.addDelegate(cleanRecorder!)

    fixFirstLaunchFrameDrop()
  }
}
