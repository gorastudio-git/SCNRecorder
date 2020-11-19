//
//  Weakify.swift
//  Example
//
//  Created by VG on 19.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation

func weakify<Self: AnyObject>(_ self: Self, _ closure: @escaping (Self) -> () -> ()) -> () -> () {
  { [weak self] in self.map { closure($0)() } }
}

func weakify<Self: AnyObject, T>(_ self: Self, _ closure: @escaping (Self) -> () -> T) -> () -> T? {
  { [weak self] in self.map { closure($0)() } }
}
