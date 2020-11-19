//
//  Atomic.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 17.05.2020.
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

public protocol Atomic: AnyObject {

  associatedtype Value

  @discardableResult
  func withValue<Result>(_ action: (Value) throws -> Result) rethrows -> Result

  @discardableResult
  func modify<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result
}

public extension Atomic {

  var value: Value {
    get { withValue { $0 } }
    set { swap(newValue) }
  }

  @discardableResult
  func swap(_ newValue: Value) -> Value {
    modify { (value: inout Value) in
      let oldValue = value
      value = newValue
      return oldValue
    }
  }
}

public extension Atomic where Value: ObservableInterface {

  var observer: Value.Observer? {
    get { value.observer }
    set { value.observer = newValue }
  }
}
