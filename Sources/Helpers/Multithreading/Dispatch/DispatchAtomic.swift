//
//  DispatchAtomic.swift
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

@propertyWrapper
public final class DispatchAtomic<Value>: Atomic {

  private var _wrappedValue: Value

  public let queue: DispatchQueue

  public var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }

  public var projectedValue: DispatchAtomic<Value> { self }

  public init(wrappedValue: Value) {
    self._wrappedValue = wrappedValue
    self.queue = DispatchQueue(label: "\(type(of: self))", attributes: [.concurrent])
  }

  public init(wrappedValue: Value, queue: DispatchQueue) {
    self._wrappedValue = wrappedValue
    self.queue = queue
  }

  @discardableResult
  public func withValue<Result>(_ action: (Value) throws -> Result) rethrows -> Result {
    try queue.sync { try action(_wrappedValue) }
  }

  @discardableResult
  public func modify<Result>(_ action: (inout Value) throws -> Result) rethrows -> Result {
    try queue.sync(flags: .barrier) { try action(&_wrappedValue) }
  }

  public func asyncModify(_ action: @escaping (inout Value) -> Void) {
    queue.async(flags: .barrier) { action(&self._wrappedValue) }
  }
}

extension DispatchAtomic: ObservableInterface where Value: ObservableInterface { }
