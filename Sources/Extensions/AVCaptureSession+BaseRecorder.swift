//
//  AVCaptureSession+BaseRecorder.swift
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

public extension AVCaptureSession {

  enum MakeError: Swift.Error {

    case defaultDeviceNotFound(type: AVMediaType)

    case canNotAddInput(input: AVCaptureInput)

    case canNotAddRecorder(recorder: BaseRecorder)
  }

  static func makeAudioForRecorder(
    _ recorder: BaseRecorder
  ) throws -> AVCaptureSession {
    let captureSession = AVCaptureSession()

    let mediaType = AVMediaType.audio
    guard let captureDevice = AVCaptureDevice.default(for: mediaType) else {
      throw MakeError.defaultDeviceNotFound(type: mediaType)
    }

    let captureInput = try AVCaptureDeviceInput(device: captureDevice)

    guard captureSession.canAddInput(captureInput) else {
      throw MakeError.canNotAddInput(input: captureInput)
    }

    captureSession.addInput(captureInput)

    guard captureSession.canAddRecorder(recorder) else {
      throw MakeError.canNotAddRecorder(recorder: recorder)
    }

    captureSession.addRecorder(recorder)
    return captureSession
  }

  func canAddRecorder(_ recorder: BaseRecorder) -> Bool {
    return canAddOutput(recorder.audioInput.captureOutput)
  }

  func addRecorder(_ recorder: BaseRecorder) {
    addOutput(recorder.audioInput.captureOutput)
  }

  func removeRecorder(_ recorder: BaseRecorder) {
    guard recorder.hasAudioInput else { return }
    removeOutput(recorder.audioInput.captureOutput)
  }
}
