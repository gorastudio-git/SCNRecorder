//
//  SCNViewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 01/07/2019.
//  Copyright © 2020 GORA Studio. All rights reserved.
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
import SceneKit
import ARKit
import AVKit

import SCNRecorder

class SCNViewController: ViewController {

  var captureSession: AVCaptureSession?

  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.allowsCameraControl = true

    do {
      guard let recorder = sceneView.recorder else { return }
      captureSession = try SCNViewController.makeAudioCaptureSessionForRecorder(recorder: recorder)
      captureSession?.startRunning()
    }
    catch {
      print("Can't start audio capture session: \(error)")
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    captureSession?.startRunning()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    captureSession?.stopRunning()
  }
}

extension SCNViewController {

  enum Error: Swift.Error {

    case defaultDeviceNotFound(type: AVMediaType)

    case canNotAddInput(input: AVCaptureInput)

    case canNotAddRecorder(recorder: SCNRecorder)
  }

  static func makeAudioCaptureSessionForRecorder(recorder: SCNRecorder) throws -> AVCaptureSession {
    let captureSession = AVCaptureSession()

    let mediaType = AVMediaType.audio
    guard let captureDevice = AVCaptureDevice.default(for: mediaType) else {
      throw Error.defaultDeviceNotFound(type: mediaType)
    }

    let captureInput = try AVCaptureDeviceInput(device: captureDevice)

    guard captureSession.canAddInput(captureInput) else {
      throw Error.canNotAddInput(input: captureInput)
    }

    captureSession.addInput(captureInput)

    guard captureSession.canAddRecorder(recorder) else {
      throw Error.canNotAddRecorder(recorder: recorder)
    }

    captureSession.addRecorder(recorder)
    return captureSession
  }
}
