//
//  MediaRecorderInput.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 24.05.2020.
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

// swiftlint:disable operator_whitespace
func ~=(pattern: MediaRecorderInput, value: MediaRecorderInput) -> Bool { value === pattern }
func ~=(pattern: MediaRecorderInput?, value: MediaRecorderInput) -> Bool { value === pattern }
// swiftlint:enable operator_whitespace

// MARK: - MediaRecorderInput
protocol MediaRecorderInputDelegate: AnyObject { }

protocol MediaRecorderInput: AnyObject {

  typealias Audio = AudioMediaRecorderInput

  typealias Video = VideoMediaRecorderInput

  typealias SampleBufferAudio = Audio & SampleBufferInput

  typealias SampleBufferVideo = Video & SampleBufferInput

  typealias PixelBufferVideo = Video & BufferInput

  var delegate: MediaRecorderInputDelegate? { get set }

  func start()

  func stop()
}

// MARK: - AudioMediaRecorderInput
protocol AudioMediaRecorderInput: MediaRecorderInput { }

// MARK: - VideoMediaRecorderInput
protocol VideoMediaRecorderInput: MediaRecorderInput {
  
  var size: CGSize { get }
  
  var videoColorProperties: [String: String]? { get }
  
  var context: CIContext { get }
}

// MARK: - SampleBufferInput

protocol SampleBufferInputDelegate: MediaRecorderInputDelegate {

  func input(_ input: SampleBufferInput, didOutput sampleBuffer: CMSampleBuffer)
}

protocol SampleBufferInput: MediaRecorderInput {

  var sampleBufferDelegate: SampleBufferInputDelegate? { get set }
}

extension SampleBufferInput {

  var sampleBufferDelegate: SampleBufferInputDelegate? {
    get { delegate as? SampleBufferInputDelegate }
    set { delegate = newValue }
  }
}

// MARK: - BufferInput

protocol BufferInputDelegate: MediaRecorderInputDelegate {

  func input(_ input: BufferInput, didOutput buffer: CVBuffer, at time: CMTime)
}

protocol BufferInput: MediaRecorderInput {

  var bufferDelegate: BufferInputDelegate? { get set }
}

extension BufferInput {

  var bufferDelegate: BufferInputDelegate? {
    get { delegate as? BufferInputDelegate }
    set { delegate = newValue }
  }
}


