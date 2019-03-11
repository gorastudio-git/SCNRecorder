//
//  WatermarkFilter.swift
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

public struct WatermarkFilter: Filter {
    
    public enum VerticalAligment {
        
        case top(padding: CGFloat)
        
        case center(padding: CGFloat)
        
        case bottom(padding: CGFloat)
        
        var padding: CGFloat {
            switch self {
            
            case .top(let padding),
                 .center(let padding),
                 .bottom(let padding):
                
                return padding
            }
        }
        
        func getTranslation(of originExtent: CGRect, on targetExtent: CGRect) -> CGFloat {
            var translation: CGFloat
            switch self {
            case .top:
                // Top difference
                translation = targetExtent.maxY - originExtent.maxY
                
            case .center:
                // Center difference
                translation = targetExtent.midY - originExtent.midY
                
            case .bottom:
                // Bottom difference
                translation = targetExtent.minY - originExtent.minY
            }
            return translation + padding
        }
    }
    
    public enum HorizontalAligment {
        
        case left(padding: CGFloat)
        
        case center(padding: CGFloat)
        
        case right(padding: CGFloat)
        
        var padding: CGFloat {
            switch self {
                
            case .left(let padding),
                 .center(let padding),
                 .right(let padding):
                
                return padding
            }
        }
        
        func getTranslation(of originExtent: CGRect, on targetExtent: CGRect) -> CGFloat {
            var translation: CGFloat
            switch self {
            case .left:
                // Left difference
                translation = targetExtent.minX - originExtent.minX
                
            case .center:
                // Center difference
                translation = targetExtent.midX - originExtent.midX
                
            case .right:
                // Right difference
                translation = targetExtent.maxX - originExtent.maxX
            }
            return translation + padding
        }
    }
    
    public let compositeFilter: Filter.Composite
    
    public let verticalAligment: VerticalAligment
    
    public let horizontalAligment: HorizontalAligment
    
    public var name: String {
        return "Recorder.WatermarkFilter"
    }
    
    public var inputKeys: [String] {
        return []
    }
    
    public init(compositeFilter: Filter.Composite,
                verticalAligment: VerticalAligment = .center(padding: 0.0),
                horizontalAligment: HorizontalAligment = .center(padding: 0.0)) {
        
        self.compositeFilter = compositeFilter
        self.verticalAligment = verticalAligment
        self.horizontalAligment = horizontalAligment
    }
    
    public init(watermark: CIImage,
                verticalAligment: VerticalAligment = .center(padding: 0.0),
                horizontalAligment: HorizontalAligment = .center(padding: 0.0)) {
        
        self.init(compositeFilter: .sourceOver(backgroundImage: watermark),
                  verticalAligment: verticalAligment,
                  horizontalAligment: horizontalAligment)
    }
    
    public func makeCIFilter(for image: CIImage) throws -> CIFilter {
        var compositeFilter = self.compositeFilter
        
        let watermark = compositeFilter.backgroundImage
        let originExtent = watermark.extent
        let targetExtent = image.extent
        
        let translationX = horizontalAligment.getTranslation(of: originExtent,
                                                             on: targetExtent)
        
        let translationY = verticalAligment.getTranslation(of: originExtent,
                                                           on: targetExtent)
        
        let transform = CGAffineTransform(translationX: translationX,
                                          y: translationY)
        
        let tranformFilter = Geometry.affineTransform(transform: transform)
        let ciTransformFilter = try tranformFilter.makeCIFilter(for: watermark)
        
        guard let transformedWatermark = ciTransformFilter.outputImage else {
            throw Error.noOutput
        }
        
        compositeFilter.setBackgroundImage(transformedWatermark)
        let swappedCompositeFilter = try compositeFilter.swapped()
        return try swappedCompositeFilter.makeCIFilter(for: image)
    }
}
