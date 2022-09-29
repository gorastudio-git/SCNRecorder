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

private var videoRecordingKey: UInt8 = 0

public enum SelfRecordableError: Swift.Error {
  case recorderNotInjected
  case videoRecordingAlreadyStarted
}

public protocol SelfRecordable: AnyObject {

  typealias Recorder = (BaseRecorder & Renderable)

  var recorder: Recorder? { get }

  var videoRecording: VideoRecording? { get set }

  func prepareForRecording()

  func injectRecorder()
}

public extension SelfRecordable {

  private var videoRecordingStorage: AssociatedStorage<VideoRecording> {
    AssociatedStorage(object: self, key: &videoRecordingKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }

  var videoRecording: VideoRecording? {
    get { videoRecordingStorage.get() }
    set { videoRecordingStorage.set(newValue) }
  }
}

extension SelfRecordable {

  func assertedRecorder(
    file: StaticString = #file,
    line: UInt = #line
  ) -> Recorder {
    assert(
      recorder != nil,
      "Please call prepareForRecording() at viewDidLoad!",
      file: file,
      line: line
    )
    return recorder!
  }
}

public extension SelfRecordable {

  func prepareForRecording() {
    guard recorder == nil else { return }
    injectRecorder()
    assert(recorder != nil)

    fixFirstLaunchFrameDrop()
  }

  // Time to time, when the first video recording is started
  // There is a small frame drop for a half of a second.
  // It happens because the first AVAssetWriter initialization takes longer that continues.
  // But reusable IOSurfaces are already captured by SCNRecorder and SceneKit can't fastly acquire them.
  // This is probably a temporary fix until I find a better one.
  // - Vlad
  internal func fixFirstLaunchFrameDrop() {
    let queue = DispatchQueue(label: "SCNRecorder.Temporarty.DispatchQueue")
    queue.async {

      var videoSettings = VideoSettings()
      videoSettings.size = CGSize(width: 1024, height: 768)

      let url = FileManager.default.temporaryDirectory.appendingPathComponent(
        "\(UUID().uuidString).\(videoSettings.fileType.fileExtension)",
        isDirectory: false
      )

      let videoOutput = try? VideoOutput(
        url: url,
        videoSettings: videoSettings,
        audioSettings: AudioSettings().outputSettings,
        queue: queue
      )

      queue.async { videoOutput?.cancel() }
      queue.async { try? FileManager.default.removeItem(at: url) }
    }
  }
}

public extension SelfRecordable where Self: MetalRecordable {

  func prepareForRecording() {
    recordableLayer?.prepareForRecording()

    guard recorder == nil else { return }
    injectRecorder()
    assert(recorder != nil)

    fixFirstLaunchFrameDrop()
  }
}

public extension SelfRecordable {

  @discardableResult
  func startVideoRecording(
    fileType: VideoSettings.FileType = .mov,
    size: CGSize? = nil
  ) throws -> VideoRecording {
    try startVideoRecording(videoSettings: VideoSettings(fileType: fileType, size: size))
  }

  func capturePixelBuffers(
    handler: @escaping (CVPixelBuffer, CMTime) -> Void
  ) -> PixelBufferOutput {
    assertedRecorder().capturePixelBuffers(handler: handler)
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
    audioSettings: AudioSettings? = nil
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
    audioSettings: AudioSettings? = nil
  ) throws -> VideoRecording {
    guard videoRecording == nil else { throw SelfRecordableError.videoRecordingAlreadyStarted }

    let videoRecording = try assertedRecorder().makeVideoRecording(
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
    orientation: UIImage.Orientation? = nil,
    completionHandler handler: @escaping (UIImage) -> Void
  ) {
    takePhotoResult(
      scale: scale,
      orientation: orientation
    ) {
      do { try handler($0.get()) }
      catch { assertionFailure("\(error)") }
    }
  }

  func takePhotoResult(
    scale: CGFloat = UIScreen.main.scale,
    orientation: UIImage.Orientation? = nil,
    handler: @escaping (Result<UIImage, Swift.Error>) -> Void
  ) {
    assertedRecorder().takePhoto(scale: scale, orientation: orientation) { photo in
      DispatchQueue.main.async { handler(photo) }
    }
  }
}
