//
//  CompositeFilter.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 11/03/2019.
//  Copyright (c) 2019 GORA Studio. https://gora.studio
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
public enum CompositeFilter {
    
    ///CIAdditionCompositing
    case addition(backgroundImage: CIImage)
    
    ///CIColorBlendMode
    case colorBlend(backgroundImage: CIImage)
    
    ///CIColorBurnBlendMode
    case colorBurnBlend(backgroundImage: CIImage)
    
    ///CIColorDodgeBlendMode
    case colorDodgeBlend(backgroundImage: CIImage)
    
    ///CIDarkenBlendMode
    case darkenBlend(backgroundImage: CIImage)
    
    ///CIDifferenceBlendMode
    case differenceBlend(backgroundImage: CIImage)
    
    ///CIDivideBlendMode
    case divideBlend(backgroundImage: CIImage)
    
    ///CIExclusionBlendMode
    case exclusionBlend(backgroundImage: CIImage)
    
    ///CIHardLightBlendMode
    case hardLightBlend(backgroundImage: CIImage)
    
    ///CIHueBlendMode
    case hueBlend(backgroundImage: CIImage)
    
    ///CILightenBlendMode
    case lightenBlend(backgroundImage: CIImage)
    
    ///CILinearBurnBlendMode
    case linearBurnBlend(backgroundImage: CIImage)
    
    ///CILinearDodgeBlendMode
    case linearDodgeBlend(backgroundImage: CIImage)
    
    ///CILuminosityBlendMode
    case luminosityBlend(backgroundImage: CIImage)
    
    ///CIMaximumCompositing
    case maximum(backgroundImage: CIImage)
    
    ///CIMinimumCompositing
    case minimum(backgroundImage: CIImage)
    
    ///CIMultiplyBlendMode
    case multiplyBlend(backgroundImage: CIImage)
    
    ///CIMultiplyCompositing
    case multiply(backgroundImage: CIImage)
    
    ///CIOverlayBlendMode
    case overlay(backgroundImage: CIImage)
    
    ///CIPinLightBlendMode
    case pinLightBlend(backgroundImage: CIImage)
    
    ///CISaturationBlendMode
    case saturationBlend(backgroundImage: CIImage)
    
    ///CIScreenBlendMode
    case screenBlend(backgroundImage: CIImage)
    
    ///CISoftLightBlendMode
    case softLightBlend(backgroundImage: CIImage)
    
    ///CISourceAtopCompositing
    case sourceAtop(backgroundImage: CIImage)
    
    ///CISourceInCompositing
    case sourceIn(backgroundImage: CIImage)
    
    ///CISourceOutCompositing
    case sourceOut(backgroundImage: CIImage)
    
    ///CISourceOverCompositing
    case sourceOver(backgroundImage: CIImage)
    
    ///CISubtractBlendMode
    case subtractBlend(backgroundImage: CIImage)
    
    var backgroundImage: CIImage {
        switch self {
            
        case .addition(let backgroundImage):
            return backgroundImage
            
        case .colorBlend(let backgroundImage):
            return backgroundImage
            
        case .colorBurnBlend(let backgroundImage):
            return backgroundImage
            
        case .colorDodgeBlend(let backgroundImage):
            return backgroundImage
            
        case .darkenBlend(let backgroundImage):
            return backgroundImage
            
        case .differenceBlend(let backgroundImage):
            return backgroundImage
            
        case .divideBlend(let backgroundImage):
            return backgroundImage
            
        case .exclusionBlend(let backgroundImage):
            return backgroundImage
            
        case .hardLightBlend(let backgroundImage):
            return backgroundImage
            
        case .hueBlend(let backgroundImage):
            return backgroundImage
            
        case .lightenBlend(let backgroundImage):
            return backgroundImage
            
        case .linearBurnBlend(let backgroundImage):
            return backgroundImage
            
        case .linearDodgeBlend(let backgroundImage):
            return backgroundImage
            
        case .luminosityBlend(let backgroundImage):
            return backgroundImage
            
        case .maximum(let backgroundImage):
            return backgroundImage
            
        case .minimum(let backgroundImage):
            return backgroundImage
            
        case .multiplyBlend(let backgroundImage):
            return backgroundImage
            
        case .multiply(let backgroundImage):
            return backgroundImage
            
        case .overlay(let backgroundImage):
            return backgroundImage
            
        case .pinLightBlend(let backgroundImage):
            return backgroundImage
            
        case .saturationBlend(let backgroundImage):
            return backgroundImage
            
        case .screenBlend(let backgroundImage):
            return backgroundImage
            
        case .softLightBlend(let backgroundImage):
            return backgroundImage
            
        case .sourceAtop(let backgroundImage):
            return backgroundImage
            
        case .sourceIn(let backgroundImage):
            return backgroundImage
            
        case .sourceOut(let backgroundImage):
            return backgroundImage
            
        case .sourceOver(let backgroundImage):
            return backgroundImage
            
        case .subtractBlend(let backgroundImage):
            return backgroundImage
        }
    }
    
    func makeCIFilter() throws -> CIFilter {
        guard let filter = CIFilter(name: name) else {
            throw Error.notFound
        }
        try filter.setBackgroundImage(backgroundImage)
        return filter
    }
}

public extension CompositeFilter {
    
    mutating func setBackgroundImage(_ backgroundImage: CIImage) {
        switch self {
            
        case .addition:
            self = .addition(backgroundImage: backgroundImage)
            
        case .colorBlend:
            self = .colorBlend(backgroundImage: backgroundImage)

        case .colorBurnBlend:
            self = .colorBurnBlend(backgroundImage: backgroundImage)

        case .colorDodgeBlend:
            self = .colorDodgeBlend(backgroundImage: backgroundImage)

        case .darkenBlend:
            self = .darkenBlend(backgroundImage: backgroundImage)

        case .differenceBlend:
            self = .differenceBlend(backgroundImage: backgroundImage)

        case .divideBlend:
            self = .divideBlend(backgroundImage: backgroundImage)

        case .exclusionBlend:
            self = .exclusionBlend(backgroundImage: backgroundImage)

        case .hardLightBlend:
            self = .hardLightBlend(backgroundImage: backgroundImage)

        case .hueBlend:
            self = .hueBlend(backgroundImage: backgroundImage)

        case .lightenBlend:
            self = .lightenBlend(backgroundImage: backgroundImage)

        case .linearBurnBlend:
            self = .linearBurnBlend(backgroundImage: backgroundImage)

        case .linearDodgeBlend:
            self = .linearDodgeBlend(backgroundImage: backgroundImage)

        case .luminosityBlend:
            self = .luminosityBlend(backgroundImage: backgroundImage)

        case .maximum:
            self = .maximum(backgroundImage: backgroundImage)

        case .minimum:
            self = .minimum(backgroundImage: backgroundImage)

        case .multiplyBlend:
            self = .multiplyBlend(backgroundImage: backgroundImage)

        case .multiply:
            self = .multiply(backgroundImage: backgroundImage)

        case .overlay:
            self = .overlay(backgroundImage: backgroundImage)

        case .pinLightBlend:
            self = .pinLightBlend(backgroundImage: backgroundImage)

        case .saturationBlend:
            self = .saturationBlend(backgroundImage: backgroundImage)

        case .screenBlend:
            self = .screenBlend(backgroundImage: backgroundImage)

        case .softLightBlend:
            self = .softLightBlend(backgroundImage: backgroundImage)

        case .sourceAtop:
            self = .sourceAtop(backgroundImage: backgroundImage)

        case .sourceIn:
            self = .sourceIn(backgroundImage: backgroundImage)

        case .sourceOut:
            self = .sourceOut(backgroundImage: backgroundImage)

        case .sourceOver:
            self = .sourceOver(backgroundImage: backgroundImage)

        case .subtractBlend:
            self = .subtractBlend(backgroundImage: backgroundImage)
        }
    }
}

extension CompositeFilter: Filter {
    
    public var inputKeys: [String] {
        return (try? makeCIFilter())?.inputKeys ?? []
    }
    
    public var name: String {
        
        switch self {
            
        case .addition:
            return "CIAdditionCompositing"
            
        case .colorBlend:
            return "CIColorBlendMode"
            
        case .colorBurnBlend:
            return "CIColorBurnBlendMode"
            
        case .colorDodgeBlend:
            return "CIColorDodgeBlendMode"
            
        case .darkenBlend:
            return "CIDarkenBlendMode"
            
        case .differenceBlend:
            return "CIDifferenceBlendMode"
            
        case .divideBlend:
            return "CIDivideBlendMode"
            
        case .exclusionBlend:
            return "CIExclusionBlendMode"
            
        case .hardLightBlend:
            return "CIHardLightBlendMode"
            
        case .hueBlend:
            return "CIHueBlendMode"
            
        case .lightenBlend:
            return "CILightenBlendMode"
            
        case .linearBurnBlend:
            return "CILinearBurnBlendMode"
            
        case .linearDodgeBlend:
            return "CILinearDodgeBlendMode"
            
        case .luminosityBlend:
            return "CILuminosityBlendMode"
            
        case .maximum:
            return "CIMaximumCompositing"
            
        case .minimum:
            return "CIMinimumCompositing"
            
        case .multiplyBlend:
            return "CIMultiplyBlendMode"
            
        case .multiply:
            return "CIMultiplyCompositing"
            
        case .overlay:
            return "CIOverlayBlendMode"
            
        case .pinLightBlend:
            return "CIPinLightBlendMode"
            
        case .saturationBlend:
            return "CISaturationBlendMode"
            
        case .screenBlend:
            return "CIScreenBlendMode"
            
        case .softLightBlend:
            return "CISoftLightBlendMode"
            
        case .sourceAtop:
            return "CISourceAtopCompositing"
            
        case .sourceIn:
            return "CISourceInCompositing"
            
        case .sourceOut:
            return "CISourceOutCompositing"
            
        case .sourceOver:
            return "CISourceOverCompositing"
            
        case .subtractBlend:
            return "CISubtractBlendMode"
        }
    }
    
    public func makeCIFilter(for image: CIImage) throws -> CIFilter {
        let filter = try makeCIFilter()
        try filter.setImage(image)
        return filter
    }
}
