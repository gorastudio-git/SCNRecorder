//
//  ImageRecorder.swift
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
import UIKit

final class ImageRecorder {
    
    static func takeUIImage(scale: CGFloat,
                            orientation: UIImage.Orientation,
                            context: CIContext,
                            completionHandler handler: @escaping (UIImage) -> Void) -> ImageRecorder {
        return takeCGImage(context: context, completionHandler: { (cgImage) in
            handler(UIImage(cgImage: cgImage, scale: scale, orientation: orientation))
        })
    }
    
    static func takeCGImage(context: CIContext,
                            completionHandler handler: @escaping (CGImage) -> Void) -> ImageRecorder {
        return takeCIImage(completionHandler: { (ciImage) in
            handler(context.createCGImage(ciImage, from: ciImage.extent)!)
        })
    }
    
    static func takeCIImage(completionHandler handler: @escaping (CIImage) -> Void) -> ImageRecorder {
        return takePixelBuffer { (pixelBuffer) in
            handler(CIImage(cvPixelBuffer: pixelBuffer))
        }
    }
    
    static func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) -> ImageRecorder {
        return ImageRecorder(completionHandler: handler)
    }
    
    var handler: ((CVPixelBuffer) -> Void)?
    
    init(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
        self.handler = { (pixelBuffer) in
            handler(pixelBuffer)
            self.handler = nil
        }
    }
}

extension ImageRecorder: PixelBufferConsumer {
    
    func setPixelBuffer(_ pixelBuffer: CVPixelBuffer, at time: TimeInterval) {
        handler?(pixelBuffer)
    }
}
