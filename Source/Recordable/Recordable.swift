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
  case preparing
  case alreadyStarted
}

public protocol Recordable: AnyObject {

  var recorder: SceneRecorder? { get set }

  var videoRecording: VideoRecording? { get set }
}

public extension Recordable {

  func prepareForRecording() throws {
    #if !DO_NOT_SWIZZLE
    if self is SCNView { SCNView.swizzle() }
    #endif //DO_NOT_SWIZZLE

    guard let recordableView = self as? RecordableView else {
      guard recorder != nil else { throw RecordableError.preparing }
      return
    }

    #if !targetEnvironment(simulator)
    recordableView.recordableLayer?.prepareForRecording()
    #endif // !targetEnvironment(simulator)

    if recorder == nil { recorder = try SceneRecorder(recordableView) }
  }

  @discardableResult
  func startVideoRecording(fileType: AVFileType = .mov) throws -> VideoRecording {
    return try startVideoRecording(
      to: FileManager.default.temporaryDirectory.appendingPathComponent(
        "\(UUID().uuidString).\(fileType.fileExtension)",
        isDirectory: false
      ),
      fileType: fileType
    )
  }

  @discardableResult
  func startVideoRecording(to url: URL, fileType: AVFileType = .mov) throws -> VideoRecording {
    guard videoRecording == nil else { throw RecordableError.alreadyStarted }

    try prepareForRecording()
    guard let recorder = recorder else { throw RecordableError.preparing }

    let videoRecording = try recorder.makeVideoRecording(to: url, fileType: fileType)
    videoRecording.resume()

    self.videoRecording = videoRecording
    return videoRecording
  }

  func finishVideoRecording(completionHandler handler: @escaping (VideoRecordingInfo) -> Void) {
    videoRecording?.finish { videoRecordingOptions in
      DispatchQueue.main.async { handler(videoRecordingOptions) }
    }
    videoRecording = nil
  }

  func takePhoto(
    scale: CGFloat = UIScreen.main.scale,
    orientation: UIImage.Orientation = .up,
    completionHandler handler: @escaping (UIImage) -> Void
  ) throws {
    try prepareForRecording()
    recorder?.takePhoto(
      scale: scale,
      orientation: orientation
    ) { photo in
      DispatchQueue.main.async { handler(photo) }
    }
  }

  func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) throws {
    try prepareForRecording()
    recorder?.takeCoreImage { coreImage in DispatchQueue.main.async { handler(coreImage) } }
  }

  func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) throws {
    try prepareForRecording()
    recorder?.takePixelBuffer { pixelBuffer in DispatchQueue.main.async { handler(pixelBuffer) } }
  }
}
