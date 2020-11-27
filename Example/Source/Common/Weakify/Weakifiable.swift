//
//  Weakifiable.swift
//  Example
//
//  Created by VG on 19.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation

protocol Weakifiable: AnyObject { }

extension Weakifiable {

  typealias `Self` = Self

  func weakify(_ closure: @escaping (Self) -> () -> Void) -> () -> Void {
    Example.weakify(self, closure)
  }

  func weakify<T>(_ closure: @escaping (Self) -> () -> T) -> () -> T? {
    Example.weakify(self, closure)
  }
}

extension NSObject: Weakifiable { }
