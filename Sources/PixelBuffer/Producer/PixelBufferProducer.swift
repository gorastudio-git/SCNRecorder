//
//  PixelBufferProducer.swift
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

enum PixelBufferProducerError: Swift.Error {

  case lockBaseAddress(errorCode: CVReturn)

  case getBaseAddress

  case emptySource

  case unlockBaseAddress(errorCode: CVReturn)

  case wrongSize
}

protocol PixelBufferProducer {

  typealias Error = PixelBufferProducerError

  var size: CGSize { get }

  var videoColorProperties: [String: String]? { get }

  var recommendedPixelBufferAttributes: [String: Any] { get }

  var context: CIContext { get }

  func startWriting()

  func writeIn(pixelBuffer: inout CVPixelBuffer) throws

  func stopWriting()
}

extension PixelBufferProducer {

  var videoColorProperties: [String: String]? { nil }

  func startWriting() { }

  func stopWriting() { }
}
