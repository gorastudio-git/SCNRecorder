//
//  SceneRecorder.VideoInput.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
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
import SceneKit

extension SceneRecorder {

  final class VideoInput: MediaRecorder.Input.PixelBufferVideo, TimeScalable {

    let timeScale: CMTimeScale

    let producer: PixelBufferProducer

    let pixelBufferPoolFactory = PixelBufferPoolFactory()
    
    var size: CGSize { producer.size }
    
    var videoColorProperties: [String : String]? { producer.videoColorProperties }

    var context: CIContext { producer.context }

    var output: ((CVBuffer, CMTime) -> Void)?

    @UnfairAtomic var started: Bool = false

    init(recordableView: SceneRecordableView, timeScale: CMTimeScale) throws {
      self.timeScale = timeScale

      switch recordableView.api {
      case .metal:
        #if !targetEnvironment(simulator)
        guard let recordableLayer = recordableView.recordableLayer else { throw Error.recordableLayer }
        self.producer = MetalPixelBufferProducer(recordableLayer: recordableLayer)
        #else // !targetEnvironment(simulator)
        throw Error.metalSimulator
        #endif // !targetEnvironment(simulator)
      case .openGLES:
        guard let eaglContext = recordableView.eaglContext else { throw Error.eaglContext }
        self.producer = EAGLPixelBufferProducer(eaglContext: eaglContext)
      case .unknown: throw Error.unknownAPI
      }
    }

    func start() {
      producer.startWriting()
      started = true
    }

    func render(atTime time: TimeInterval) throws {
      guard started, let output = output else { return }

      let attributes = producer.recommendedPixelBufferAttributes
      let pixelBufferPool = try pixelBufferPoolFactory.makeWithAttributes(attributes)
      var pixelBuffer = try CVPixelBuffer.makeWithPixelBufferPool(pixelBufferPool)
      try producer.writeIn(pixelBuffer: &pixelBuffer)

      output(pixelBuffer, timeFromSeconds(time))
    }

    func stop() {
      producer.stopWriting()
      started = false
    }
  }
}

// MARK: - Error
extension SceneRecorder.VideoInput {

  enum Error: Swift.Error {

    case recordableLayer

    case eaglContext

    case metalSimulator

    case unknownAPI
  }
}
