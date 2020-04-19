//
//  RecordableView.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 13/03/2019.
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
import UIKit
import SceneKit

public protocol RecordableView: Recordable {

  #if !targetEnvironment(simulator)
  var recordableLayer: RecordableLayer? { get }
  #endif // !targetEnvironment(simulator)

  var eaglContext: EAGLContext? { get }

  var api: API { get }
}

public extension RecordableView where Self: UIView {

  #if !targetEnvironment(simulator)
  var recordableLayer: RecordableLayer? { return layer as? RecordableLayer }
  #endif // !targetEnvironment(simulator)
}

public extension RecordableView where Self: SCNView {

  var api: API {
    switch renderingAPI {
    case .metal: return .metal
    case .openGLES2: return .openGLES
    #if compiler(>=5)
    @unknown default: return .unknown
    #endif // compiler(>=5)
    }
  }
}
