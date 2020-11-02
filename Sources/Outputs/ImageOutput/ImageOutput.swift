//
//  ImageOutput.swift
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
import AVFoundation
import UIKit
import VideoToolbox

final class ImageOutput {

  static func takeUIImage(
    scale: CGFloat,
    orientation: UIImage.Orientation,
    context: CIContext,
    completionHandler handler: @escaping (ImageOutput, UIImage) -> Void
  ) -> ImageOutput {
    takeCGImage(context: context) {
      handler($0, UIImage(cgImage: $1, scale: scale, orientation: orientation))
    }
  }

  static func takeCIImage(
    context: CIContext,
    completionHandler handler: @escaping (ImageOutput, CIImage) -> Void
  ) -> ImageOutput {
    takeCGImage(context: context) {
      handler($0, CIImage(cgImage: $1))
    }
  }

  static func takeCGImage(
    context: CIContext,
    completionHandler handler: @escaping (ImageOutput, CGImage) -> Void
  ) -> ImageOutput {
    takePixelBuffer {
      var image: CGImage?
      VTCreateCGImageFromCVPixelBuffer($1, options: nil, imageOut: &image)
      handler($0, image!)
    }
  }

  static func takePixelBuffer(
    completionHandler handler: @escaping (ImageOutput, CVPixelBuffer) -> Void
  ) -> ImageOutput {
    ImageOutput(completionHandler: handler)
  }

  var handler: ((ImageOutput, CVPixelBuffer) -> Void)?

  init(completionHandler handler: @escaping (ImageOutput, CVPixelBuffer) -> Void) {
    self.handler = { (imageOutput, pixelBuffer) in
      handler(imageOutput, pixelBuffer)
      self.handler = nil
    }
  }
}

extension ImageOutput: MediaSession.Output.Video {

  func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
    guard let imageBuffer: CVImageBuffer = {
      if #available(iOS 13.0, *) {
        return sampleBuffer.imageBuffer
      } else {
        return CMSampleBufferGetImageBuffer(sampleBuffer)
      }
    }() else { return }
    handler?(self, imageBuffer)
  }

  func appendVideoBuffer(_ buffer: CVBuffer, at time: CMTime) {
    handler?(self, buffer)
  }
}
