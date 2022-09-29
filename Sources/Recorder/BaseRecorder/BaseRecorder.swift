//
//  BaseRecorder.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 25.05.2020.
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
import CoreMedia
import ARKit

public class BaseRecorder: NSObject {

  let mediaSession: MediaSession

  var hasAudioInput = false

  lazy var audioInput: AudioInput = {
    let audioInput = AudioInput(queue: queue)
    hasAudioInput = true
    mediaSession.setAudioInput(audioInput)
    return audioInput
  }()

  let queue: DispatchQueue

  @Observable public internal(set) var error: Swift.Error?

  public var useAudioEngine: Bool {
    get { audioInput.useAudioEngine }
    set { audioInput.useAudioEngine = newValue }
  }

  init(queue: DispatchQueue, mediaSession: MediaSession) {
    self.queue = queue
    self.mediaSession = mediaSession
    super.init()
    self.mediaSession.$error.observe { [weak self] in self?.error = $0 }
  }

  public func makeVideoRecording(
    to url: URL,
    videoSettings: VideoSettings,
    audioSettings: AudioSettings?
  ) throws -> VideoRecording {
    try mediaSession.makeVideoRecording(
      to: url,
      videoSettings: videoSettings,
      audioSettings: audioSettings
    )
  }

  public func capturePixelBuffers(
    handler: @escaping (CVPixelBuffer, CMTime) -> Void
  ) -> PixelBufferOutput {
    mediaSession.capturePixelBuffers(handler: handler)
  }

  public func takePhoto(
    scale: CGFloat,
    orientation: UIImage.Orientation?,
    handler: @escaping (Result<UIImage, Swift.Error>) -> Void
  ) {
    mediaSession.takePhoto(
      scale: scale,
      orientation: orientation,
      handler: handler
    )
  }

  public func takeCoreImage(handler: @escaping (Result<CIImage, Swift.Error>) -> Void) {
    mediaSession.takeCoreImage(handler: handler)
  }

  public func takePixelBuffer(handler: @escaping (Result<CVPixelBuffer, Swift.Error>) -> Void) {
    mediaSession.takePixelBuffer(handler: handler)
  }
}

// MARK: - ARSessionDelegate
extension BaseRecorder: ARSessionDelegate {

  @objc public func session(
    _ session: ARSession,
    didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer
  ) {
    audioInput.session(session, didOutputAudioSampleBuffer: audioSampleBuffer)
  }
}
