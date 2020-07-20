//
//  Recordable.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 30.12.2019.
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
import UIKit
import AVFoundation
import SceneKit

enum RecordableError: Swift.Error {
  case preparation
  case alreadyStarted
}

public protocol Recordable: AnyObject {

  var recorder: Recorder? { get }

  var videoRecording: VideoRecording? { get set }
}

public extension Recordable {

  func prepareForRecording() throws {
    if self is SCNView { SCNView.swizzle() }

    if let this = self as? SceneRecordableView {
      #if !targetEnvironment(simulator)
      this.recordableLayer?.prepareForRecording()
      #endif // !targetEnvironment(simulator)

      this.sceneRecorder = try this.sceneRecorder ?? SceneRecorder(this)
    }
    
    if let this = self as? InternalCleanRecordable {
      this.cleanRecorder = this.cleanRecorder ?? {
        let cleanRecorder = CleanRecorder(this)
        this.scnView.addDelegate(cleanRecorder)
        return cleanRecorder
      }()
    }

    if recorder == nil { throw RecordableError.preparation }
  }

  @discardableResult
  func startVideoRecording(settings: VideoSettings = VideoSettings()) throws -> VideoRecording {
    return try startVideoRecording(
      to: FileManager.default.temporaryDirectory.appendingPathComponent(
        "\(UUID().uuidString).\(settings.fileType.fileExtension)",
        isDirectory: false
      ),
      settings: settings
    )
  }
  
  @discardableResult
  func startVideoRecording(
    to url: URL,
    settings: VideoSettings = VideoSettings()
  ) throws -> VideoRecording {
    guard videoRecording == nil else { throw RecordableError.alreadyStarted }

    try prepareForRecording()
    guard let recorder = recorder else { throw RecordableError.preparation }

    let videoRecording = try recorder.makeVideoRecording(to: url, settings: settings)
    videoRecording.resume()

    self.videoRecording = videoRecording
    return videoRecording
  }

  func finishVideoRecording(completionHandler handler: @escaping (VideoRecordingInfo) -> Void) {
    videoRecording?.finish { videoRecordingInfo in
      DispatchQueue.main.async { handler(videoRecordingInfo) }
    }
    videoRecording = nil
  }

  func cancelVideoRecording() {
    videoRecording?.cancel()
    videoRecording = nil
  }

  func takePhoto(
    scale: CGFloat = UIScreen.main.scale,
    orientation: UIImage.Orientation = .up,
    completionHandler handler: @escaping (UIImage) -> Void
  ) throws {
    try prepareForRecording()
    recorder?.takePhoto(scale: scale, orientation: orientation) { photo in
      DispatchQueue.main.async { handler(photo) }
    }
  }
}
