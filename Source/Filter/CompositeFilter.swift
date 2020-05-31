//
//  CompositeFilter.swift
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

///CICategoryCompositeOperation
public struct CompositeFilter {

  enum `Type`: String {

    case addition = "CIAdditionCompositing"

    case colorBlend = "CIColorBlendMode"

    case colorBurnBlend = "CIColorBurnBlendMode"

    case colorDodgeBlend = "CIColorDodgeBlendMode"

    case darkenBlend = "CIDarkenBlendMode"

    case differenceBlend = "CIDifferenceBlendMode"

    case divideBlend = "CIDivideBlendMode"

    case exclusionBlend = "CIExclusionBlendMode"

    case hardLightBlend = "CIHardLightBlendMode"

    case hueBlend = "CIHueBlendMode"

    case lightenBlend = "CILightenBlendMode"

    case linearBurnBlend = "CILinearBurnBlendMode"

    case linearDodgeBlend = "CILinearDodgeBlendMode"

    case luminosityBlend = "CILuminosityBlendMode"

    case maximum = "CIMaximumCompositing"

    case minimum = "CIMinimumCompositing"

    case multiplyBlend = "CIMultiplyBlendMode"

    case multiply = "CIMultiplyCompositing"

    case overlay = "CIOverlayBlendMode"

    case pinLightBlend = "CIPinLightBlendMode"

    case saturationBlend = "CISaturationBlendMode"

    case screenBlend = "CIScreenBlendMode"

    case softLightBlend = "CISoftLightBlendMode"

    case sourceAtop = "CISourceAtopCompositing"

    case sourceIn = "CISourceInCompositing"

    case sourceOut = "CISourceOutCompositing"

    case sourceOver = "CISourceOverCompositing"

    case subtractBlend = "CISubtractBlendMode"
  }

  var type: Type

  var backgroundImage: CIImage
}

extension CompositeFilter: Filter {

  public var inputKeys: [String] { (try? makeCIFilter())?.inputKeys ?? [] }

  public var name: String { type.rawValue }

  public func makeCIFilter() throws -> CIFilter {
    guard let filter = CIFilter(name: name) else { throw Error.notFound }
    try filter.setBackgroundImage(backgroundImage)
    return filter
  }
}
