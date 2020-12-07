//
//  MetalPixelBufferProducerTests.swift
//  SCNRecorderTests
//
//  Created by Vladislav Grigoryev on 04.12.2020.
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
import Metal

final class MetalPixelBufferProducerTests: XCTestCase {

  let testingQueue = DispatchQueue(label: "TestingQueue")

  var recordableLayer: TestRecordableLayer!

  var metalPixelBufferProducer: MetalPixelBufferProducer!

  override func tearDown() {
    recordableLayer = nil
    metalPixelBufferProducer = nil
  }

  func testProducing() {
    TestRecordableLayer.testPixelFormats.forEach { (pixelFormat) in
      do {
        try prepareForPixelFormat(pixelFormat)
        try produceWithPixelFormat(pixelFormat) { (result) in
          do {
            let cvPixelBuffer = try result.get()
            let pixelBuffer = PixelBuffer(cvPixelBuffer)

            XCTAssertEqual(pixelBuffer.pixelFormat, pixelFormat.supportedPixelFormat.pixelFormatType)
            XCTAssertEqual(pixelBuffer.width, Int(self.recordableLayer.bounds.width))
            XCTAssertEqual(pixelBuffer.height, Int(self.recordableLayer.bounds.height))

            let attachments = pixelBuffer.propagatedAttachments
            XCTAssertNotNil(attachments?[kCVImageBufferCGColorSpaceKey as String])
            XCTAssertNotNil(attachments?[kCVImageBufferICCProfileKey as String])
          }
          catch {
            XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
          }
        }
      }
      catch {
        XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
      }
    }
  }

  func testBGRA8UnormPerfomance() throws {
    let pixelFormat: MTLPixelFormat = .bgra8Unorm
    try prepareForPixelFormat(pixelFormat)
    
    measure {
      do {
        try produceWithPixelFormat(pixelFormat, handler: { _ in })
      }
      catch {
        XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
      }
    }
  }

  #if !targetEnvironment(simulator)

  func testBGRA8UnormSRGBPerfomance() throws {
    let pixelFormat: MTLPixelFormat = .bgra8Unorm_srgb
    try prepareForPixelFormat(pixelFormat)

    measure {
      do {
        try produceWithPixelFormat(pixelFormat, handler: { _ in })
      }
      catch {
        XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
      }
    }
  }

  func testBGR10XRPerfomance() throws {
    let pixelFormat: MTLPixelFormat = .bgr10_xr
    try prepareForPixelFormat(pixelFormat)

    measure {
      do {
        try produceWithPixelFormat(pixelFormat, handler: { _ in })
      }
      catch {
        XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
      }
    }
  }

  func testBGR10XRSRGBPerfomance() throws {
    let pixelFormat: MTLPixelFormat = .bgr10_xr_srgb
    try prepareForPixelFormat(pixelFormat)

    measure {
      do {
        try produceWithPixelFormat(pixelFormat, handler: { _ in })
      }
      catch {
        XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
      }
    }
  }

  func testBGRA10XRPerfomance() throws {
    let pixelFormat: MTLPixelFormat = .bgra10_xr
    try prepareForPixelFormat(pixelFormat)

    measure {
      do {
        try produceWithPixelFormat(pixelFormat, handler: { _ in })
      }
      catch {
        XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
      }
    }
  }

  func testBGRA10XRSRGBPerfomance() throws {
    let pixelFormat: MTLPixelFormat = .bgra10_xr_srgb
    try prepareForPixelFormat(pixelFormat)

    measure {
      do {
        try produceWithPixelFormat(pixelFormat, handler: { _ in })
      }
      catch {
        XCTFail("Pixel Format: \(pixelFormat.name), error: \(error)")
      }
    }
  }

  #endif
}

extension MetalPixelBufferProducerTests {

  func prepareForPixelFormat(_ pixelFormat: MTLPixelFormat) throws {
    let recordableLayer = try TestRecordableLayer(pixelFormat: pixelFormat)
    recordableLayer.prepareForRecording()
    try recordableLayer.render()

    self.recordableLayer = recordableLayer
    self.metalPixelBufferProducer = try MetalPixelBufferProducer(
      recordableLayer: recordableLayer,
      queue: testingQueue
    )
  }

  func produceWithPixelFormat(
    _ pixelFormat: MTLPixelFormat,
    handler: @escaping (MetalPixelBufferProducer.CVPixelBufferResult) -> Void
  ) throws {
    guard let recordableLayer = self.recordableLayer,
          let producer = self.metalPixelBufferProducer,
          recordableLayer.pixelFormat == pixelFormat
    else {
      XCTFail("Not Preparad for \(pixelFormat.name)")
      return
    }

    let exp = expectation(description: "Pixel buffer is produced")

    try producer.produce(using: recordableLayer.testRenderer.commandQueue) { (result) in
      handler(result)
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }
}
