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

final class VideoRecorder {

  let assetWriter: AssetWriter

  let videoInput: VideoInput

  let audioInput: AudioInput

  let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor

  let queue: DispatchQueue

  var state: State {
    didSet {
      recording?.state.value = state.recordingState
      if state.isFinal { onFinalState(self) }
    }
  }

  var duration: TimeInterval = 0.0 {
    didSet { recording?.duration.value = duration }
  }

  var lastSeconds: TimeInterval = 0.0

  var onFinalState: (VideoRecorder) -> Void = { _ in }

  weak var recording: Recording? {
    didSet { recording?.state.value = state.recordingState }
  }

  init(
    url: URL,
    fileType: AVFileType,
    videoConfiguration: VideoConfiguration,
    queue: DispatchQueue
  ) throws {
    assetWriter = try AssetWriter(url: url, fileType: fileType)

    videoInput = VideoInput(videoConfiguration)
    guard assetWriter.canAdd(videoInput) else { throw Error.cantAddVideoAssetWriterInput }
    assetWriter.add(videoInput)

    audioInput = AudioInput()
    guard assetWriter.canAdd(audioInput) else { throw Error.cantAddAudioAssterWriterInput }
    assetWriter.add(audioInput)

    pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput)
    guard assetWriter.startWriting() else { throw assetWriter.error ?? Error.cantStartWriting }

    self.queue = queue
    self.state = .ready
  }

  deinit { state = state.cancel(self) }
}

extension VideoRecorder {

  func startSession(at sourceTime: CMTime) {
    lastSeconds = sourceTime.seconds
    assetWriter.startSession(atSourceTime: sourceTime)
  }

  func endSession(at sourceTime: CMTime) {
    assetWriter.endSession(atSourceTime: sourceTime)
  }

  func finishWriting(completionHandler handler: @escaping () -> Void) {
    assetWriter.finishWriting(completionHandler: handler)
  }

  func cancelWriting() {
    assetWriter.cancelWriting()
  }

  func append(pixelBuffer: CVPixelBuffer, withPresentationTime time: CMTime) throws {
    guard pixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData else { return }
    guard pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: time) else {
      if assetWriter.status == .failed { throw assetWriter.error ?? Error.unknown }
      return
    }

    let seconds = time.seconds
    duration += seconds - lastSeconds
    lastSeconds = seconds
  }

  func appendVideo(sampleBuffer: CMSampleBuffer) throws {
    guard videoInput.isReadyForMoreMediaData else { return }
    guard videoInput.append(sampleBuffer) else {
      if assetWriter.status == .failed { throw assetWriter.error ?? Error.unknown }
      return
    }

    let timeStamp: CMTime
    let duration: CMTime

    if #available(iOS 13.0, *) {
      timeStamp = sampleBuffer.presentationTimeStamp
      duration = sampleBuffer.duration
    } else {
      timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
      duration = CMSampleBufferGetDuration(sampleBuffer)
    }

    self.duration += duration.seconds
    lastSeconds = (timeStamp + duration).seconds
  }

  func appendAudio(sampleBuffer: CMSampleBuffer) throws {
    guard audioInput.isReadyForMoreMediaData else { return }
    guard audioInput.append(sampleBuffer) else {
      if assetWriter.status == .failed { throw assetWriter.error ?? Error.unknown }
      return
    }
  }
}

extension VideoRecorder {

  func makeRecording() -> Recording {
    let recording = Recording(videoRecorder: self)
    self.recording = recording
    return recording
  }
}

// - MARK: Getters
extension VideoRecorder {

  var url: URL { assetWriter.outputURL }

  var fileType: AVFileType { assetWriter.outputFileType }
}

// - MARK: Lifecycle
extension VideoRecorder {

  func resume() {
    queue.async { [weak self] in self?.unsafeResume() }
  }

  func pause() {
    queue.async { [weak self] in self?.unsafePause() }
  }

  func finish(completionHandler handler: @escaping () -> Void) {
    queue.async { [weak self] in self?.unsafeFinish(completionHandler: handler) }
  }

  func cancel() {
    queue.async { [weak self] in self?.unsafeCancel() }
  }
}

// - MARK: Unsafe Lifecycle
private extension VideoRecorder {

  func unsafeResume() { state = state.resume(self) }

  func unsafePause() { state = state.pause(self) }

  func unsafeFinish(completionHandler handler: @escaping () -> Void) {
    state = state.finish(self, completionHandler: handler)
  }

  func unsafeCancel() { state = state.cancel(self) }
}

// - MARK: VideoOutput
extension VideoRecorder: VideoOutput {

  func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
    state = state.appendVideoSampleBuffer(sampleBuffer, to: self)
  }

  func appendVideoBuffer(_ buffer: CVBuffer, at time: CMTime) {
    state = state.appendVideoBuffer(buffer, at: time, to: self)
  }
}

// - MARK: AudioOutput
extension VideoRecorder: AudioOutput {

  func appendAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
    state = state.appendAudioSampleBuffer(sampleBuffer, to: self)
  }
}
