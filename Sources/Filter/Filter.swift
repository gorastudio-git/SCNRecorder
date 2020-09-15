//
//  Filter.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 11/03/2019.
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

public enum FilterError: Swift.Error {
  case copy
  case notFound
  case notApplicable(key: String)
  case notSpecified(key: String)
  case noOutput
}

public protocol Filter {

  typealias Error = FilterError

  typealias Composite = CompositeFilter

  typealias Watermark = WatermarkFilter

  var name: String { get }

  var inputKeys: [String] { get }

  func makeCIFilter() throws -> CIFilter
}

public extension Filter {

  func makeCIFilter(for image: CIImage) throws -> CIFilter {
    let filter = try makeCIFilter()
    try filter.setImage(image)
    return filter
  }

  func swapped() throws -> Filter {
    guard inputKeys.contains(kCIInputBackgroundImageKey) else {
      throw Error.notApplicable(key: kCIInputBackgroundImageKey)
    }
    return SwappingFilter(filter: self)
  }
}
