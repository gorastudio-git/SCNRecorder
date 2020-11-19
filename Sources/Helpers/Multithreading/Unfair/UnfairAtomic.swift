//
//  UnfairAtomic.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 29.12.2019.
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

@propertyWrapper
public final class UnfairAtomic<Value>: Atomic {

  private let lock = UnfairLock()

  private var _wrappedValue: Value

  public var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }

  public var projectedValue: UnfairAtomic<Value> { self }

  public init(wrappedValue: Value) { self._wrappedValue = wrappedValue }

  @discardableResult
  public func withValue<Result>(_ action: (Value) throws -> Result) rethrows -> Result {
    try lock.locked { try action(_wrappedValue) }
  }

  @discardableResult
  public func modify<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result {
    try lock.locked { try action(&_wrappedValue) }
  }
}

extension UnfairAtomic: ObservableInterface where Value: ObservableInterface { }
