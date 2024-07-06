//
//  PixelBufferOutput.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 06.10.2020.
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

final public class PixelBufferOutput {
    
  final class Weak: VideoMediaSessionOutput {

    weak var output: PixelBufferOutput?

    var deinitHandler: ((Weak) -> Void)?

    init(output: PixelBufferOutput, deinitHandler: @escaping (Weak) -> Void) {
      self.output = output
      self.deinitHandler = deinitHandler
    }

    func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
      guard let output = output else {
        deinitHandler?(self)
        deinitHandler = nil
        return
      }
      output.appendVideoSampleBuffer(sampleBuffer)
    }

    func appendVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer, at time: CMTime) {
      guard let output = output else {
        deinitHandler?(self)
        deinitHandler = nil
        return
      }
      output.appendVideoPixelBuffer(pixelBuffer, at: time)
    }
  }

  var handler: (CVPixelBuffer, CMTime) -> Void

  init(handler: @escaping (CVPixelBuffer, CMTime) -> Void) {
    self.handler = handler
  }
}

extension PixelBufferOutput: VideoMediaSessionOutput {

  func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
    guard let imageBuffer: CVImageBuffer = {
      if #available(iOS 13.0, *) {
        return sampleBuffer.imageBuffer
      } else {
        return CMSampleBufferGetImageBuffer(sampleBuffer)
      }
    }() else { return }

    let time: CMTime
    if #available(iOS 13.0, *) {
      time = sampleBuffer.presentationTimeStamp
    } else {
      time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    }

    handler(imageBuffer, time)
  }

  func appendVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer, at time: CMTime) {
    handler(pixelBuffer, time)
  }
}
