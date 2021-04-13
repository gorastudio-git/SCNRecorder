//
//  Observable.swift
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

public protocol ObservableInterface: AnyObject {

  associatedtype Property

  typealias Observer = (Property) -> Void

  var observer: Observer? { get set }
}

@propertyWrapper
public final class Observable<Property>: ObservableInterface {

  public typealias Observer = (Property) -> Void

  public var wrappedValue: Property {
    didSet { observer?(wrappedValue) }
  }

  public var value: Property { wrappedValue }

  public var projectedValue: Observable<Property> { self }

  public var observer: Observer?

  public init(wrappedValue: Property) { self.wrappedValue = wrappedValue }
}

public extension ObservableInterface {

  func observe(
    on queue: DispatchQueue? = nil,
    _ observer: @escaping Observer
  ) {
    // swiftlint:disable opening_brace
    self.observer = queue.map { queue in
      { value in queue.async { observer(value) }}
    } ?? observer
    // swiftlint:enable opening_brace
  }
}

public extension ObservableInterface where Property: Equatable {

  func observeUnique(
    on queue: DispatchQueue? = nil,
    _ observer: @escaping Observer
  ) {
    var oldValue: Property?
    observe(on: queue) { (value) in
      guard oldValue != value else { return }
      observer(value)
      oldValue = value
    }
  }
}
