//
//  CIFilter+Helpers.swift
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

public extension CIFilter {
  
  func testIfApplicable(key: String) throws {
    guard inputKeys.contains(key) else { throw Error.notApplicable(key: key) }
  }
  
  func setImage(_ image: CIImage) throws {
    try testIfApplicable(key: kCIInputImageKey)
    setValue(image, forKey: kCIInputImageKey)
  }
  
  func setBackgroundImage(_ backgroundImage: CIImage) throws {
    try testIfApplicable(key: kCIInputBackgroundImageKey)
    setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
  }
  
  func setAffineTransform(_ affineTransform: CGAffineTransform) throws {
    try testIfApplicable(key: kCIInputTransformKey)
    setValue(NSValue(cgAffineTransform: affineTransform), forKey: kCIInputTransformKey)
  }
  
  func setRectangle(_ rectange: CGRect) throws {
    try testIfApplicable(key: "inputRectangle")
    setValue(CIVector(cgRect: rectange), forKey: "inputRectangle")
  }
  
  func setScale(_ scale: CGFloat) throws {
    try testIfApplicable(key: kCIInputScaleKey)
    setValue(scale, forKey: kCIInputScaleKey)
  }
  
  func setAspectRatio(_ aspectRatio: CGFloat) throws {
    try testIfApplicable(key: kCIInputAspectRatioKey)
    setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
  }
  
  func setTopLeft(_ topLeft: CGPoint) throws {
    try testIfApplicable(key: "inputTopLeft")
    setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
  }
  
  func setTopRight(_ topRight: CGPoint) throws {
    try testIfApplicable(key: "inputTopRight")
    setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
  }
  
  func setBottomLeft(_ bottomLeft: CGPoint) throws {
    try testIfApplicable(key: "inputBottomRight")
    setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomRight")
  }
  
  func setBottomRight(_ bottomRight: CGPoint) throws {
    try testIfApplicable(key: "inputBottomLeft")
    setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomLeft")
  }
  
  func setExtent(_ extent: CGRect) throws {
    try testIfApplicable(key: kCIInputExtentKey)
    setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
  }
  
  func setAngle(_ angle: CGFloat) throws {
    try testIfApplicable(key: kCIInputAngleKey)
    setValue(angle, forKey: kCIInputAngleKey)
  }
}
