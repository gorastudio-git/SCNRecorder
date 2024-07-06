//
//  SceneRecorderTests.swift
//  SCNRecorderTests
//
//  Created by Vladislav Grigoryev on 05.12.2020.
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

import XCTest
@testable import SCNRecorder
import AVFoundation

final class SceneRecorderTests: XCTestCase {

  var recordableLayer: TestRecordableLayer!

  var recorder: SceneRecorder!

  func testVideoRecording() { _testVideoRecording() }

  func testTakingPhoto() { _testTakingPhoto() }
}

// MARK: - Preparation
extension SceneRecorderTests {

  func prepareForPixelFormat(_ pixelFormat: MTLPixelFormat) throws {
    let recordableLayer = try TestRecordableLayer(pixelFormat: pixelFormat)
    recordableLayer.prepareForRecording()
    try recordableLayer.render()
    self.recordableLayer = recordableLayer
    self.recorder = try SceneRecorder(recordableLayer)
  }
}

// MARK: - Video Recording Tests
extension SceneRecorderTests {

  func _testVideoRecording() {
    TestRecordableLayer.testPixelFormats.forEach { (pixelFormat) in
      _testVideoRecording(pixelFormat: pixelFormat)
    }
  }

  func _testVideoRecording(pixelFormat: MTLPixelFormat) {
    VideoSettings.FileType.allCases.forEach { (fileType) in
      _testVideoRecording(pixelFormat: pixelFormat, fileType: fileType)
    }
  }

  func _testVideoRecording(
    pixelFormat: MTLPixelFormat,
    fileType: VideoSettings.FileType
  ) {
    var codecs: [VideoSettings.Codec] = [.h264()]

    #if !targetEnvironment(simulator)
    let supportHEVCEncoder = AVAssetExportSession.allExportPresets().contains(AVAssetExportPresetHEVC1920x1080)
    if supportHEVCEncoder {
      codecs.append(.hevc())
      if #available(iOS 13.0, *) {
        if fileType == .mov {
          codecs.append(.hevcWithAlpha())
        }
      }
    }

    codecs.append(.jpeg())
    #endif

    codecs.forEach { (codec) in
      _testVideoRecording(pixelFormat: pixelFormat, fileType: fileType, codec: codec)
    }
  }

  func _testVideoRecording(
    pixelFormat: MTLPixelFormat,
    fileType: VideoSettings.FileType,
    codec: VideoSettings.Codec
  ) {
    func makeErrorMessage(_ message: String, error: Swift.Error? = nil) -> String {
      """
        \(message)
        PixelFormat: \(pixelFormat.name),
        Extension: \(fileType.fileExtension),
        Codec: \(codec.name),
        Error: \(String(describing: error))
      """
    }

    let fileName = "video.\(pixelFormat.name).\(codec.name).\(fileType.fileExtension)"

    let fileManager = FileManager.default
    let url = fileManager.temporaryDirectory.appendingPathComponent(fileName)

    try? fileManager.removeItem(at: url)
    addTeardownBlock { try? fileManager.removeItem(at: url) }

    do {
      try prepareForPixelFormat(pixelFormat)

      let exp = expectation(description: "Video recording is finished")

      let videoRecording = try recorder.makeVideoRecording(
        to: url,
        videoSettings: VideoSettings(fileType: fileType, codec: codec),
        audioSettings: AudioSettings()
      )
      videoRecording.resume()

      let renderingInterval: TimeInterval = 0.1
      let timer = Timer.scheduledTimer(withTimeInterval: renderingInterval, repeats: true) { _ in
        self.recorder.render(using: self.recordableLayer.testRenderer.commandQueue)
      }

      let duration: TimeInterval = 1.0
      let epsilon = 2.0 * renderingInterval
      DispatchQueue.main.asyncAfter(deadline: .now() + duration + epsilon) {
        timer.invalidate()
        videoRecording.finish { (info) in
          XCTAssertGreaterThanOrEqual(info.duration, duration - epsilon)
          exp.fulfill()
        }
      }

      wait(for: [exp], timeout: duration * 2.0)

      XCTAssertNil(
        recorder.error,
        makeErrorMessage("Recorder error.", error: recorder.error)
      )

      XCTAssertEqual(
        videoRecording.state,
        .finished,
        makeErrorMessage("Video recording state is not finished: \(videoRecording.state).")
      )
    }
    catch {
      XCTFail(makeErrorMessage("Video recording error.", error: error))
    }
  }
}

// MARK: - Photo Tests
extension SceneRecorderTests {

  func _testTakingPhoto() {
    TestRecordableLayer.testPixelFormats.forEach { (pixelFormat) in
      _testTakingPhoto(pixelFormat: pixelFormat)
    }
  }

  func _testTakingPhoto(
    pixelFormat: MTLPixelFormat
  ) {
    func makeErrorMessage(_ message: String, error: Swift.Error? = nil) -> String {
      """
        \(message)
        PixelFormat: \(pixelFormat.name),
        Error: \(String(describing: error))
      """
    }

    do {
      try prepareForPixelFormat(pixelFormat)

      let renderingInterval: TimeInterval = 0.1
      let timer = Timer.scheduledTimer(withTimeInterval: renderingInterval, repeats: true) { _ in
        self.recorder.render(using: self.recordableLayer.testRenderer.commandQueue)
      }

      let exp = expectation(description: "Photo is taken")
      recorder.takePhoto(scale: 1.0, orientation: .up) { (result) in
        timer.invalidate()

        do {
          let photo = try result.get()
          let format = UIGraphicsImageRendererFormat()
          format.scale = 1.0
          format.preferredRange = pixelFormat.isWideGamut ? .extended : .standard
          let data = UIGraphicsImageRenderer(size: photo.size, format: format).jpegData(
            withCompressionQuality: 1.0
          ) { (context) in
            photo.draw(at: .zero)
          }

          let attachement = XCTAttachment(data: data, uniformTypeIdentifier: "public.jpeg")
          attachement.name = pixelFormat.name
          attachement.lifetime = .keepAlways
          self.add(attachement)

          XCTAssertEqual(photo.size.width, self.recordableLayer.bounds.width)
          XCTAssertEqual(photo.size.height, self.recordableLayer.bounds.height)
        }
        catch {
          XCTFail(makeErrorMessage("Photo error.", error: error))
        }

        exp.fulfill()
      }

      wait(for: [exp], timeout: 1.0)

      XCTAssertNil(
        recorder.error,
        makeErrorMessage("Recorder error.", error: recorder.error)
      )
    }
    catch {
      XCTFail(makeErrorMessage("Photo error.", error: error))
    }
  }
}


