//
//  Observable.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

import Foundation

public protocol ObservableInterface: AnyObject {

  associatedtype Property

  typealias Observer = (Property) -> Void

  var observer: Observer? { get set }
}

@propertyWrapper
public final class Observable<Property>: ObservableInterface {

  public typealias Observer = (Property) -> Void

  public internal(set) var wrappedValue: Property {
    didSet { observer?(wrappedValue) }
  }

  public var value: Property { wrappedValue }

  public var projectedValue: Observable<Property> { self }

  public var observer: Observer?

  public init(wrappedValue: Property) { self.wrappedValue = wrappedValue }
}

public extension ObservableInterface {

  func observe(_ observer: @escaping Observer) { self.observer = observer }
}

public extension ObservableInterface where Property: Equatable {

  func observeUnique(_ observer: @escaping Observer) {
    var oldValue: Property? = nil
    observe { (value) in
      guard oldValue != value else { return }
      observer(value)
      oldValue = value
    }
  }
}
