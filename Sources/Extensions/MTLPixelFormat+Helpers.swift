//
//  MTLPixelFormat+Helpers.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 23/03/2019.
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
import AVFoundation

extension MTLPixelFormat {

  // Undocumented format, something like bgr10_xr_srgb, was obtained on iPhone 7 iOS 12.1.4
  static let undocumented_bgr10_xr_srgb = MTLPixelFormat(rawValue: 551) ?? .bgr10_xr_srgb

  var colorSpace: CGColorSpace {
    var colorSpace: CGColorSpace?

    switch self {
    case .bgr10_xr_srgb, .undocumented_bgr10_xr_srgb:
      colorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB)
    default:
      colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
    }
    return colorSpace ?? CGColorSpaceCreateDeviceRGB()
  }

  var iccData: CFData? { colorSpace.copyICCData() }

  var videoColorProperties: [String: String] {
    switch self {
    case .bgr10_xr_srgb, .undocumented_bgr10_xr_srgb:
      return [ AVVideoColorPrimariesKey: AVVideoColorPrimaries_P3_D65,
               AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
               AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2 ]
    default:
      return [ AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
               AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
               AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2 ]
    }
  }

  var pixelFormatType: OSType {
    switch self {

    case .bgra8Unorm, .bgra8Unorm_srgb:
      return kCVPixelFormatType_32BGRA

    case .rgba16Float:
      return kCVPixelFormatType_64RGBAHalf

    case .bgr10_xr, .bgr10_xr_srgb, .undocumented_bgr10_xr_srgb:
      return kCVPixelFormatType_30RGBLEPackedWideGamut

    case .bgr10a2Unorm:
      return kCVPixelFormatType_ARGB2101010LEPacked

      // So far there are no public core video pixel formats for metal pixel formats below
//    case .bgra10_xr, .bgra10_xr_srgb:
//    case .rgb10a2Unorm:

    default:
      return kCVPixelFormatType_32BGRA
    }
  }
}
