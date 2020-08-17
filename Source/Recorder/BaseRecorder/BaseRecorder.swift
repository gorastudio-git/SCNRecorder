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
import SceneKit
import ARKit

public class BaseRecorder: NSObject {

  let mediaRecorder: MediaRecorder

  lazy var audioInput: AudioInput = {
    let audioInput = AudioInput(queue: queue)
    mediaRecorder.audioInput = audioInput
    return audioInput
  }()

  let queue = DispatchQueue(label: "SCNRecorder.Processing.DispatchQueue", qos: .userInitiated)

  public var filters: [Filter] {
    get { mediaRecorder.filters }
    set { mediaRecorder.filters = newValue }
  }

  @Observable var error: Swift.Error?

  public override init() {
    self.mediaRecorder = MediaRecorder(queue: queue)
    super.init()
    self.mediaRecorder.$error.observe { [weak self] in self?.error = $0 }
  }

  public func makeVideoRecording(to url: URL, settings: VideoSettings) throws -> VideoRecording {
    try mediaRecorder.makeVideoRecording(to: url, settings: settings)
  }

  public func takePhoto(
    scale: CGFloat,
    orientation: UIImage.Orientation,
    completionHandler handler: @escaping (UIImage) -> Void
  ) {
    mediaRecorder.takePhoto(
      scale: scale,
      orientation: orientation,
      completionHandler: handler
    )
  }

  public func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) {
    mediaRecorder.takeCoreImage(completionHandler: handler)
  }

  public func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
    mediaRecorder.takePixelBuffer(completionHandler: handler)
  }
}

// MARK: - ARSCNViewDelegate
extension BaseRecorder: ARSCNViewDelegate {

  @objc public func session(
    _ session: ARSession,
    didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer
  ) {
    audioInput.session(session, didOutputAudioSampleBuffer: audioSampleBuffer)
  }
}
