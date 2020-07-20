//
//  CleanRecorder.VideoInput.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

import Foundation
import AVFoundation
import SceneKit

extension CleanRecorder {

  final class VideoInput: MediaRecorder.Input.PixelBufferVideo, TimeScalable {

    let cleanRecordable: CleanRecordable

    let timeScale: CMTimeScale
    
    var size: CGSize {
      guard let buffer = cleanRecordable.cleanPixelBuffer else { return .zero }
      return CGSize(
        width: buffer.width,
        height: buffer.height
      )
    }
    
    var videoColorProperties: [String : String]? { nil }

    var context: CIContext { CIContext() }

    weak var delegate: MediaRecorderInputDelegate?

    @UnfairAtomic var started: Bool = false

    init(cleanRecordable: CleanRecordable, timeScale: CMTimeScale) {
      self.cleanRecordable = cleanRecordable
      self.timeScale = timeScale
    }

    func start() { started = true }

    func stop() { started = false }
  }
}

// MARK: - SCNSceneRendererDelegate
extension CleanRecorder.VideoInput {

  func renderer(
    _ renderer: SCNSceneRenderer,
    didRenderScene scene: SCNScene,
    atTime time: TimeInterval
  ) throws {
    guard started, bufferDelegate != nil else { return }
    guard let pixelBuffer = cleanRecordable.cleanPixelBuffer else { return }

    bufferDelegate?.input(self, didOutput: pixelBuffer, at: timeFromSeconds(time))
  }
}
