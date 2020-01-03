//
//  SwappingFilter.swift
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

struct SwappingFilter {
  
  let filter: Filter
}

extension SwappingFilter: Filter {
  
  public var name: String { return filter.name }
  
  public var inputKeys: [String] { return filter.inputKeys }
  
  public func makeCIFilter(for image: CIImage) throws -> CIFilter {
    let ciFilter = try filter.makeCIFilter(for: image)
    
    guard let backgroundImage = ciFilter.value(forKey: kCIInputBackgroundImageKey) as? CIImage
      else { throw Error.notSpecified(key: kCIInputBackgroundImageKey) }
    
    try ciFilter.setImage(backgroundImage)
    try ciFilter.setBackgroundImage(image)
    
    return ciFilter
  }
}
