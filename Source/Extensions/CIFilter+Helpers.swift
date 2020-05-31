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
    guard inputKeys.contains(key) else { throw Filter.Error.notApplicable(key: key) }
  }

  func setValue(_ value: @autoclosure () -> Any, ifApplicableForKey key: String) throws {
    try testIfApplicable(key: key)
    setValue(value(), forKey: key)
  }

  func setImage(_ image: CIImage) throws {
    try setValue(image, ifApplicableForKey: kCIInputImageKey)
  }

  func setBackgroundImage(_ backgroundImage: CIImage) throws {
    try setValue(backgroundImage, ifApplicableForKey: kCIInputBackgroundImageKey)
  }

  func setAffineTransform(_ affineTransform: CGAffineTransform) throws {
    try setValue(
      NSValue(cgAffineTransform: affineTransform),
      ifApplicableForKey: kCIInputTransformKey
    )
  }

  func setRectangle(_ rectange: CGRect) throws {
    try setValue(CIVector(cgRect: rectange), ifApplicableForKey: "inputRectangle")
  }

  func setScale(_ scale: CGFloat) throws {
    try setValue(scale, ifApplicableForKey: kCIInputScaleKey)
  }

  func setAspectRatio(_ aspectRatio: CGFloat) throws {
    try setValue(aspectRatio, ifApplicableForKey: kCIInputAspectRatioKey)
  }

  func setTopLeft(_ topLeft: CGPoint) throws {
    try setValue(CIVector(cgPoint: topLeft), ifApplicableForKey: "inputTopLeft")
  }

  func setTopRight(_ topRight: CGPoint) throws {
    try setValue(CIVector(cgPoint: topRight), ifApplicableForKey: "inputTopRight")
  }

  func setBottomLeft(_ bottomLeft: CGPoint) throws {
    try setValue(CIVector(cgPoint: bottomLeft), ifApplicableForKey: "inputBottomLeft")
  }

  func setBottomRight(_ bottomRight: CGPoint) throws {
    try setValue(CIVector(cgPoint: bottomRight), ifApplicableForKey: "inputBottomRight")
  }

  func setExtent(_ extent: CGRect) throws {
    try setValue(CIVector(cgRect: extent), ifApplicableForKey: kCIInputExtentKey)
  }

  func setAngle(_ angle: CGFloat) throws {
    try setValue(angle, ifApplicableForKey: kCIInputAngleKey)
  }
}
