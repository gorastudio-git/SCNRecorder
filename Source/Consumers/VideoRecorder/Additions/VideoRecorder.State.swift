//
//  VideoRecorder.State.swift
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

  /// Finite-State Machine
  enum State {
    case ready
    case preparing
    case recording(seconds: TimeInterval)
    case paused

    case canceled
    case finished
    case failed(error: Swift.Error)

    var isFinal: Bool {
      switch self {
      case .ready,
           .preparing,
           .recording,
           .paused:
        return false

      case .canceled,
           .finished,
           .failed:
        return true
      }
    }

    var recordingState: SCNVideoRecording.State {
      switch self {
      case .ready: return .ready
      case .preparing: return .preparing
      case .recording: return .recording
      case .paused: return .paused
      case .canceled: return .canceled
      case .finished: return .finished
      case .failed(let error): return .failed(error)
      }
    }

    func resume(_ videoRecorder: VideoRecorder) -> State {
      switch self {

      case .ready,
           .preparing:
        return .preparing

      case .recording(let seconds):
        return .recording(seconds: seconds)

      case .paused:
        return .preparing

      case .canceled,
           .finished,
           .failed:
        return self
      }
    }

    func pause(_ videoRecorder: VideoRecorder) -> State {
      switch  self {

      case .ready,
           .preparing:
        return .ready

      case .recording(let seconds):
        videoRecorder.endSession(at: seconds)
        return .paused

      case .paused,
           .canceled,
           .finished,
           .failed:
        return self
      }
    }

    func finish(_ videoRecorder: VideoRecorder, completionHandler handler: @escaping () -> Void) -> State {
      switch self {

      case .ready,
           .preparing:
        handler()
        return .canceled

      case .recording,
           .paused:
        videoRecorder.finishWriting(completionHandler: handler)
        return .finished

      case .canceled,
           .finished,
           .failed:
        handler()
        return self
      }
    }

    func cancel(_ videoRecorder: VideoRecorder) -> State {
      switch  self {

      case .ready,
           .preparing:
        return .canceled

      case .recording,
           .paused:
        videoRecorder.cancelWriting()
        return .canceled

      case .canceled,
           .finished,
           .failed:
        return self
      }
    }

    func appendPixelBuffer(
      _ pixelBuffer: CVPixelBuffer,
      at time: TimeInterval,
      to videoRecorder: VideoRecorder
    ) -> State {
      do { return try _appendPixelBuffer(pixelBuffer, at: time, to: videoRecorder) }
      catch { return .failed(error: error) }
    }

    func appendAudioSampleBuffer(
      _ audioSampleBuffer: CMSampleBuffer,
      to videoRecorder: VideoRecorder
    ) -> State {
      do { return try _appendAudioSampleBuffer(audioSampleBuffer, to: videoRecorder) }
      catch { return .failed(error: error) }
    }
  }
}

private extension VideoRecorder.State {

  func _appendPixelBuffer(
    _ pixelBuffer: CVPixelBuffer,
    at time: TimeInterval,
    to videoRecorder: VideoRecorder
  ) throws -> VideoRecorder.State {
    switch self {

    case .ready:
      return self

    case .preparing:
      videoRecorder.startSession(at: time)
      try videoRecorder.append(pixelBuffer, withSeconds: time)
      return .recording(seconds: time)

    case .recording:
      try videoRecorder.append(pixelBuffer, withSeconds: time)
      return .recording(seconds: time)

    case .paused,
         .canceled,
         .finished,
         .failed:
      return self
    }
  }

  func _appendAudioSampleBuffer(
    _ audioSampleBuffer: CMSampleBuffer,
    to videoRecorder: VideoRecorder
  ) throws -> VideoRecorder.State {
    switch self {

    case .ready,
         .preparing:
      return self

    case .recording(let seconds):
      try videoRecorder.append(audioSampleBuffer)
      return .recording(seconds: seconds)

    case .paused,
         .canceled,
         .finished,
         .failed:
      return self
    }
  }
}
