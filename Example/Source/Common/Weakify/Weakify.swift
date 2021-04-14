//
//  Weakify.swift
//  Example
//
//  Created by Vladislav Grigoryev on 19.11.2020.
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

func weakify<This: AnyObject>(
  _ this: This,
  _ closure: @escaping (This) -> () -> Void
) -> () -> Void {
  Global.weakify(this, closure)
}

func weakify<This: AnyObject, Result>(
  _ this: This,
  _ closure: @escaping (This) -> () -> Result
) -> () -> Result? {
  Global.weakify(this, closure)
}

func weakify<This: AnyObject, Parameter>(
  _ this: This,
  _ closure: @escaping (This) -> (Parameter) -> Void
) -> (Parameter) -> Void {
  Global.weakify(this, closure)
}

func weakify<This: AnyObject, Parameter, Result>(
  _ this: This,
  _ closure: @escaping (This) -> (Parameter) -> Result
) -> (Parameter) -> Result? {
  Global.weakify(this, closure)
}

enum Global {

  static func weakify<This: AnyObject>(
    _ this: This,
    _ closure: @escaping (This) -> () -> Void
  ) -> () -> Void {
    { [weak this] in this.map { closure($0)() } }
  }

  static func weakify<This: AnyObject, Result>(
    _ this: This,
    _ closure: @escaping (This) -> () -> Result
  ) -> () -> Result? {
    { [weak this] in this.map { closure($0)() } }
  }

  static func weakify<This: AnyObject, Parameter>(
    _ this: This,
    _ closure: @escaping (This) -> (Parameter) -> Void
  ) -> (Parameter) -> Void {
    { [weak this] (parameter) in
      this.map { closure($0)(parameter) }
    }
  }

  static func weakify<This: AnyObject, Parameter, Result>(
    _ this: This,
    _ closure: @escaping (This) -> (Parameter) -> Result
  ) -> (Parameter) -> Result? {
    { [weak this] (parameter) in
      this.map { closure($0)(parameter)
      }
    }
  }
}
