//
//  GeometryFilter.swift
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

///CICategoryGeometryAdjustment
public enum GeometryFilter {
  
  ///CIAffineTransform
  case affineTransform(transform: CGAffineTransform)
  
  ///CICrop
  case crop(rectangle: CGRect)
  
  ///CILanczosScaleTransform
  case lanczosScale(scale: CGFloat, aspectRatio: CGFloat)
  
  ///CIPerspectiveCorrection
  case perspectiveCorrection(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint)
  
  ///CIPerspectiveTransform
  case perspectiveTransform(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint)
  
  ///CIPerspectiveTransformWithExtent
  case perspectiveTransformWithExtent(extent: CGRect, topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint)
  
  ///CIStraightenFilter
  case strainghten(angle: CGFloat)
  
  func makeCIFilter() throws -> CIFilter {
    guard let filter = CIFilter(name: name) else { throw Error.notFound }
    
    switch self {
    case .affineTransform(let transform):
      try filter.setAffineTransform(transform)
      
    case .crop(let rectangle):
      try filter.setRectangle(rectangle)
      
    case .lanczosScale(let scale, let aspectRatio):
      try filter.setScale(scale)
      try filter.setAspectRatio(aspectRatio)
      
    case .perspectiveTransformWithExtent(
      let extent,
      let topLeft,
      let topRight,
      let bottomRight,
      let bottomLeft
      ):
      try filter.setExtent(extent)
      fallthrough
      
    case .perspectiveCorrection(let topLeft, let topRight, let bottomRight, let bottomLeft),
         .perspectiveTransform(let topLeft, let topRight, let bottomRight, let bottomLeft):
      try filter.setTopLeft(topLeft)
      try filter.setTopRight(topRight)
      try filter.setBottomRight(bottomRight)
      try filter.setBottomLeft(bottomLeft)
      
    case .strainghten(let angle):
      try filter.setAngle(angle)
    }
    
    return filter
  }
}

extension GeometryFilter: Filter {
  
  public var inputKeys: [String] { return (try? makeCIFilter().inputKeys) ?? [] }
  
  public var name: String {
    switch self {
    case .affineTransform: return "CIAffineTransform"
    case .crop: return "CICrop"
    case .lanczosScale: return "CILanczosScaleTransform"
    case .perspectiveCorrection: return "CIPerspectiveCorrection"
    case .perspectiveTransform: return "CIPerspectiveTransform"
    case .perspectiveTransformWithExtent: return "CIPerspectiveTransformWithExtent"
    case .strainghten: return "CIStraightenFilter"
    }
  }
  
  public func makeCIFilter(for image: CIImage) throws -> CIFilter {
    let filter = try makeCIFilter()
    try filter.setImage(image)
    return filter
  }
}
