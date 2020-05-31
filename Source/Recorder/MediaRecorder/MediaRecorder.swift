//
//  MediaRecorder.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 24.05.2020.
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

final class MediaRecorder: InternalRecorder {

  typealias Input = MediaRecorderInput

  typealias Output = MediaRecorderOutput

  let queue: DispatchQueue

  @UnfairAtomic var filters = [Filter]()

  @UnfairAtomic var videoOutputs = [Output.Video]()

  @UnfairAtomic var audioOutputs = [Output.Audio]()

  @Observable var error: Swift.Error?

  var errorObserver: Observable<Swift.Error?> { $error }

  var videoInput: Input.Video? {
    didSet {
      oldValue?.delegate = nil
      videoInput?.delegate = self
    }
  }

  var audioInput: Input.SampleBufferAudio? {
    didSet {
      oldValue?.delegate = nil
      audioInput?.delegate = self
    }
  }

  public init(
    queue: DispatchQueue = DispatchQueue(
      label: "MediaRecorder.Processing",
      qos: .userInitiated
    )
  ) {
    self.queue = queue
  }
}

extension MediaRecorder: BufferInputDelegate {

  func input(_ input: BufferInput, didOutput buffer: CVBuffer, at time: CMTime) {
    do {
      switch input {
      case let videoInput as Input.Video where videoInput === self.videoInput:
        guard !videoOutputs.isEmpty else { return }
        try buffer.applyFilters(filters, using: videoInput.context)
        appendVideoBuffer(buffer, at: time)

      default: break
      }
    }
    catch { self.error = error  }
  }
}

extension MediaRecorder: SampleBufferInputDelegate {

  func input(_ input: SampleBufferInput, didOutput sampleBuffer: CMSampleBuffer) {
    switch input {
    case videoInput:
      guard !videoOutputs.isEmpty else { return }
      appendVideoBuffer(sampleBuffer)

    case audioInput:
      guard !audioOutputs.isEmpty else { return }
      appendAudioBuffer(sampleBuffer)

    default: break
    }
  }
}

extension MediaRecorder {

  func appendVideoBuffer(_ buffer: CVBuffer, at time: CMTime) {
    queue.async { [weak self] in
      self?.videoOutputs.forEach { $0.appendVideoBuffer(buffer, at: time) }
    }
  }

  func appendVideoBuffer(_ sampleBuffer: CMSampleBuffer) {
    queue.async { [weak self] in
      self?.videoOutputs.forEach { $0.appendVideoSampleBuffer(sampleBuffer) }
    }
  }
}

extension MediaRecorder {

  func appendAudioBuffer(_ sampleBuffer: CMSampleBuffer) {
    queue.async { [weak self] in
      self?.audioOutputs.forEach { $0.appendAudioSampleBuffer(sampleBuffer) }
    }
  }
}

extension MediaRecorder {

  func makeVideoRecording(to url: URL, fileType: AVFileType = .mov) throws -> VideoRecording {
    guard let videoInput = videoInput else { throw NSError() }

    let videoConfiguration = VideoRecorder.VideoConfiguration.Builder()
    videoConfiguration.videoSettings = videoInput.recommendedVideoSettings

    let videoRecorder = try VideoRecorder(
      url: url,
      fileType: fileType,
      videoConfiguration: videoConfiguration.build(),
      queue: queue
    )

    videoRecorder.onFinalState = { [weak self] in
      self?.removeVideoOutput($0)
      self?.removeAudioOutput($0)
    }

    addVideoOutput(videoRecorder)
    addAudioOutput(videoRecorder)
    return videoRecorder.makeRecording()
  }

  func takePhoto(
    scale: CGFloat,
    orientation: UIImage.Orientation,
    completionHandler handler: @escaping (UIImage) -> Void
  ) {
    guard let videoInput = videoInput else { return }

    addVideoOutput(
      ImageRecorder.takeUIImage(
        scale: scale,
        orientation: orientation,
        context: videoInput.context,
        completionHandler: { [weak self] in
          self?.removeVideoOutput($0)
          handler($1)
        }
      )
    )
  }

  func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) {
    addVideoOutput(
      ImageRecorder.takeCIImage(
        completionHandler: { [weak self] in
          self?.removeVideoOutput($0)
          handler($1)
        }
      )
    )
  }

  func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
    addVideoOutput(
      ImageRecorder.takePixelBuffer(
        completionHandler: { [weak self] in
          self?.removeVideoOutput($0)
          handler($1)
        }
      )
    )
  }
}

extension MediaRecorder {

  func addVideoOutput(_ videoOutput: MediaRecorder.Output.Video) {
    if ($videoOutputs.modify {
      $0.append(videoOutput)
      return $0.count == 1
    }) { videoInput?.start() }
  }

  func removeVideoOutput(_ videoOutput: MediaRecorder.Output.Video) {
    if ($videoOutputs.modify {
      $0 = $0.filter { $0 !== videoOutput }
      return $0.count == 0
    }) { videoInput?.stop() }
  }

  func addAudioOutput(_ audioOutput: MediaRecorder.Output.Audio) {
    if ($audioOutputs.modify {
      $0.append(audioOutput)
      return $0.count == 1
    }) { audioInput?.start() }
  }

  func removeAudioOutput(_ audioOutput: MediaRecorder.Output.Audio) {
    if ($audioOutputs.modify {
      $0 = $0.filter { $0 !== audioOutput }
      return $0.count == 0
    }) { audioInput?.stop() }
  }
}
