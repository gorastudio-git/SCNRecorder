//
//  Observable.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

import Foundation

@propertyWrapper
public final class Observable<Property> {

  public typealias WillSetObserver = (_ change: (value: Property, newValue: Property)) -> Void

  public typealias DidSetObserver = (_ change: (oldValue: Property, value: Property)) -> Void

  public internal(set) var wrappedValue: Property {
    willSet { willSet?((wrappedValue, newValue))}
    didSet { didSet?((oldValue, wrappedValue))}
  }

  public var value: Property { wrappedValue }

  public var willSet: WillSetObserver?

  public var didSet: DidSetObserver?

  public var projectedValue: Observable<Property> { self }

  public init(wrappedValue: Property) { self.wrappedValue = wrappedValue }
}
