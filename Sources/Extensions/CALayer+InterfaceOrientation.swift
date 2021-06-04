//
//  CALayer+Window.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 03.06.2021.
//  Copyright © 2021 GORA Studio. https://gora.studio
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

extension CALayer {

  var window: UIWindow? {
    (delegate as? UIView)?.window
      ?? superlayer?.window
      ?? UIApplication.shared.keyWindow
  }

  public var interfaceOrientation: UIInterfaceOrientation {
    if #available(iOS 13.0, *) {
      return window?.windowScene?.interfaceOrientation ?? _interfaceOrientation
    } else {
      return _interfaceOrientation
    }
  }

  private var _interfaceOrientation: UIInterfaceOrientation {
    guard let window = window else { return .unknown }
    let fixedCoordinateSpace = window.screen.fixedCoordinateSpace

    let origin = convert(frame.origin, to: window.layer)
    let fixedOrigin = window.convert(origin, to: fixedCoordinateSpace)

    let isXGreater = fixedOrigin.x > origin.x
    let isYGreater = fixedOrigin.y > origin.y

    switch (isXGreater, isYGreater) {
    case (true, true): return .portraitUpsideDown
    case (true, false): return .landscapeRight
    case (false, true): return .landscapeLeft
    case (false, false): return .portrait
    }
  }
}
