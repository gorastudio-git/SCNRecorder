//
//  SceneRecorder.VideoInput.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

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

    weak var delegate: MediaRecorderInputDelegate?

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

// MARK: - SCNSceneRendererDelegate
extension SceneRecorder.VideoInput {

  func renderer(
    _ renderer: SCNSceneRenderer,
    didRenderScene scene: SCNScene,
    atTime time: TimeInterval
  ) throws {
    guard started, bufferDelegate != nil else { return }

    let attributes = producer.recommendedPixelBufferAttributes
    let pixelBufferPool = try pixelBufferPoolFactory.makeWithAttributes(attributes)
    var pixelBuffer = try CVPixelBuffer.makeWithPixelBufferPool(pixelBufferPool)
    try producer.writeIn(pixelBuffer: &pixelBuffer)

    bufferDelegate?.input(self, didOutput: pixelBuffer, at: timeFromSeconds(time))
  }
}
