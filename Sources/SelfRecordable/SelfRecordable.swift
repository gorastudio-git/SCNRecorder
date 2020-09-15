//
//  SelfRecordable.swift
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
import ARKit

public enum SelfRecordableError: Swift.Error {
  case recorderNotInjected
  case videoRecordingAlreadyStarted
}

public protocol SelfRecordable: AnyObject {

  var recorder: (BaseRecorder & Renderable)? { get }

  var videoRecording: VideoRecording? { get set }

  func prepareForRecording()

  func injectRecorder()
}

public extension SelfRecordable {

  func prepareForRecording() {
    guard recorder == nil else { return }
    injectRecorder()
    assert(recorder != nil)
  }
}

#if !targetEnvironment(simulator)

public extension SelfRecordable where Self: MetalRecordable {

  func prepareForRecording() {
    (recordableLayer as? CAMetalLayer)?.swizzle()

    guard recorder == nil else { return }
    injectRecorder()

    assert(recorder != nil)
  }
}

#endif // !targetEnvironment(simulator)

public extension SelfRecordable {

  @discardableResult
  func startVideoRecording(
    fileType: VideoSettings.FileType = .mov,
    size: CGSize? = nil
  ) throws -> VideoRecording {
    try startVideoRecording(videoSettings: VideoSettings(fileType: fileType, size: size))
  }

  @discardableResult
  func startVideoRecording(
    to url: URL,
    fileType: VideoSettings.FileType = .mov,
    size: CGSize? = nil
  ) throws -> VideoRecording {
    try startVideoRecording(to: url, videoSettings: VideoSettings(fileType: fileType, size: size))
  }

  @discardableResult
  func startVideoRecording(
    videoSettings: VideoSettings,
    audioSettings: AudioSettings = AudioSettings()
  ) throws -> VideoRecording {
    return try startVideoRecording(
      to: FileManager.default.temporaryDirectory.appendingPathComponent(
        "\(UUID().uuidString).\(videoSettings.fileType.fileExtension)",
        isDirectory: false
      ),
      videoSettings: videoSettings,
      audioSettings: audioSettings
    )
  }

  @discardableResult
  func startVideoRecording(
    to url: URL,
    videoSettings: VideoSettings,
    audioSettings: AudioSettings = AudioSettings()
  ) throws -> VideoRecording {
    guard videoRecording == nil else { throw SelfRecordableError.videoRecordingAlreadyStarted }

    prepareForRecording()
    guard let recorder = recorder else { throw SelfRecordableError.recorderNotInjected }

    let videoRecording = try recorder.makeVideoRecording(
      to: url,
      videoSettings: videoSettings,
      audioSettings: audioSettings
    )
    videoRecording.resume()

    self.videoRecording = videoRecording
    return videoRecording
  }

  func finishVideoRecording(completionHandler handler: @escaping (VideoRecording.Info) -> Void) {
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
    prepareForRecording()
    recorder?.takePhoto(scale: scale, orientation: orientation) { photo in
      DispatchQueue.main.async { handler(photo) }
    }
  }
}
