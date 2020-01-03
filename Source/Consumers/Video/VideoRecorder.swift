//
//  VideoRecorder.swift
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

extension VideoRecorder {
  
  enum Error: Swift.Error {
    
    case fileAlreadyExists
    
    case notStarted
    
    case wrongState
  }
}

final class VideoRecorder {
  
  let timeScale: CMTimeScale
  
  let assetWriter: AVAssetWriter
  
  let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
  
  let audioAssetWriterInput: AVAssetWriterInput?
  
  let queue: DispatchQueue
  
  var state: State = .ready {
    didSet {
      recording?.state.value = state.recordingState
      if state.isFinal { onFinalState(self) }
    }
  }
  
  var duration: TimeInterval = 0.0 { didSet { recording?.duration.value = duration } }
  
  var startSeconds: TimeInterval = 0.0
  
  weak var recording: Recording?
  
  var onFinalState: (VideoRecorder) -> Void = { _ in }
  
  var url: URL { return assetWriter.outputURL }
  
  var fileType: AVFileType { return assetWriter.outputFileType }
  
  init(
    url: URL,
    fileType: AVFileType,
    videoSettings: [String: Any],
    videoSourceFormatHint: CMFormatDescription?,
    audioSettings: [String: Any],
    audioSourceFormatHint: CMFormatDescription?,
    timeScale: CMTimeScale,
    transform: CGAffineTransform,
    queue: DispatchQueue
  ) throws {
    self.timeScale = timeScale
    assetWriter = try AVAssetWriter(url: url, fileType: fileType)
    
    let videoAssetWriterInput = AVAssetWriterInput(
      mediaType: .video,
      outputSettings: videoSettings,
      sourceFormatHint: nil
    )
    videoAssetWriterInput.transform = transform
    videoAssetWriterInput.expectsMediaDataInRealTime = true
    
    if assetWriter.canAdd(videoAssetWriterInput) {
      assetWriter.add(videoAssetWriterInput)
      pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: videoAssetWriterInput,
        sourcePixelBufferAttributes: nil
      )
    }
    else { pixelBufferAdaptor = nil }
    
    let audioAssetWriterInput = AVAssetWriterInput(
      mediaType: .audio,
      outputSettings: nil,
      sourceFormatHint: audioSourceFormatHint
    )
    audioAssetWriterInput.expectsMediaDataInRealTime = true
    
    if assetWriter.canAdd(audioAssetWriterInput) {
      assetWriter.add(audioAssetWriterInput)
      self.audioAssetWriterInput = audioAssetWriterInput
    }
    else { self.audioAssetWriterInput = nil }
    
    guard assetWriter.startWriting() else { throw assetWriter.error ?? Error.notStarted }

    self.queue = queue
  }
  
  deinit { state = state.cancel(self) }
}

extension VideoRecorder {
  
  func startSession(at seconds: TimeInterval) {
    startSeconds = seconds + 0.2
    assetWriter.startSession(atSourceTime: timeFromSeconds(seconds))
  }
  
  func endSession(at seconds: TimeInterval) {
    assetWriter.endSession(atSourceTime: timeFromSeconds(seconds))
  }
  
  func finishWriting(completionHandler handler: @escaping () -> Void) {
    assetWriter.finishWriting(completionHandler: handler)
  }
  
  func cancelWriting() {
    assetWriter.cancelWriting()
  }
  
  func append(_ pixelBuffer: CVPixelBuffer, withSeconds seconds: TimeInterval) {
    guard
      let adaptor = pixelBufferAdaptor,
      adaptor.assetWriterInput.isReadyForMoreMediaData,
      adaptor.append(pixelBuffer, withPresentationTime: timeFromSeconds(seconds))
    else { return }
    
    duration = seconds - startSeconds
  }
  
  func append(_ sampleBuffer: CMSampleBuffer) {
    guard let input = audioAssetWriterInput,
          input.isReadyForMoreMediaData,
          input.append(sampleBuffer)
    else { return }
  }
}

extension VideoRecorder {
  
  func makeRecording() -> VideoRecording {
    let recording = Recording(videoRecorder: self)
    self.recording = recording
    return recording
  }
}

extension VideoRecorder {
  
  func resume(onError: @escaping (Swift.Error) -> Void) {
    queue.async { [weak self] in
      do {
        guard let this = self else { return }
        this.state = try this.state.resume(this)
      }
      catch { onError(error) }
    }
  }
  
  func pause() {
    queue.async { [weak self] in
      guard let this = self else { return }
      this.state = this.state.pause(this)
    }
  }
  
  func finish(completionHandler handler: @escaping () -> Void) {
    queue.async { [weak self] in
      guard let this = self else { return }
      this.state = this.state.finish(this, completionHandler: handler)
    }
  }
  
  func cancel() {
    queue.async { [weak self] in
      guard let this = self else { return }
      this.state = this.state.cancel(this)
    }
  }
}

// - MARK: PixelBufferConsumer
extension VideoRecorder: PixelBufferConsumer {
  
  func appendPixelBuffer(_ pixelBuffer: CVPixelBuffer, at time: TimeInterval) {
    state = state.appendPixelBuffer(pixelBuffer, at: time, to: self)
  }
}

// - MARK: AudioSampleBufferConsumer
extension VideoRecorder: AudioSampleBufferConsumer {
  
  func appendAudioSampleBuffer(_ audioSampleBuffer: CMSampleBuffer) {
    state = state.appendAudioSampleBuffer(audioSampleBuffer, to: self)
  }
}

// - MARK: Internal Helpers
extension VideoRecorder {
  
  func timeFromSeconds(_ seconds: TimeInterval) -> CMTime {
    return CMTime(seconds: seconds, preferredTimescale: timeScale)
  }
}
