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
import CoreVideo

enum ImageOutput {

  enum Error: Swift.Error {

    case createCGImageFromCVPixelBufferFailed(_ status: OSStatus)
  }

  static func takeUIImage(
    scale: CGFloat,
    orientation: UIImage.Orientation,
    handler: @escaping (Result<UIImage, Swift.Error>) -> Void
  ) -> (Result<CVPixelBuffer, Swift.Error>) -> Void {
    takeCGImage { result in
      handler(
        result.map {
          UIImage(cgImage: $0, scale: scale, orientation: orientation)
        }
      )
    }
  }

  static func takeCIImage(
    handler: @escaping (Result<CIImage, Swift.Error>) -> Void
  ) -> (Result<CVPixelBuffer, Swift.Error>) -> Void {
    takeCGImage { result in
      handler(
        result.map {
          CIImage(cgImage: $0)
        }
      )
    }
  }

  static func takeCGImage(
    handler: @escaping (Result<CGImage, Swift.Error>) -> Void
  ) -> (Result<CVPixelBuffer, Swift.Error>) -> Void {
    {
      handler($0.flatMap { pixelBuffer in
        var cgImage: CGImage?
        let status = VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let image = cgImage else {
          return .failure(Error.createCGImageFromCVPixelBufferFailed(status))
        }
        return .success(image)
      })
    }
  }

  static func takePixelBuffer(
    handler: @escaping (Result<CVPixelBuffer, Swift.Error>) -> Void
  ) -> (CVPixelBuffer, CMTime) -> Void {
    { (pixelBuffer, _) in
      handler(.success(pixelBuffer))
    }
  }
}
