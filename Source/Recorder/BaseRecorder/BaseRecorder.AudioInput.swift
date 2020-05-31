//
//  BaseRecorder.AudioInput.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

import Foundation
import AVFoundation
import ARKit

extension BaseRecorder {

  final class AudioInput: NSObject, MediaRecorder.Input.SampleBufferAudio {

    let queue: DispatchQueue

    weak var delegate: MediaRecorderInputDelegate?

    lazy var output: AVCaptureAudioDataOutput = {
      let output = AVCaptureAudioDataOutput()
      output.setSampleBufferDelegate(self, queue: queue)
      return output
    }()

    init(queue: DispatchQueue) { self.queue = queue }

    func start() { }

    func stop() { }
  }
}

extension BaseRecorder.AudioInput: AVCaptureAudioDataOutputSampleBufferDelegate {

  @objc func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    sampleBufferDelegate?.input(self, didOutput: sampleBuffer)
  }
}

extension BaseRecorder.AudioInput: ARSessionObserver {

  func session(
    _ session: ARSession,
    didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer
  ) {
    sampleBufferDelegate?.input(self, didOutput: audioSampleBuffer)
  }
}
