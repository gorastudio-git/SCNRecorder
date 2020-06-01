//
//  CleanRecordable.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 25.05.2020.
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

private var cleanRecorderKey: UInt8 = 0

public protocol CleanRecordable: AnyObject {

  var scnView: SCNView { get }

  var cleanRecorder: CleanRecorder? { get set }

  var cleanVideoRecording: VideoRecording? { get set }

  var cleanPixelBuffer: CVPixelBuffer? { get }

  var clean: Recordable { get }
}

extension CleanRecordable {

  public var clean: Recordable { Clean(clean: self) }
}

private final class Clean: CleanRecordable, Recordable {

  var scnView: SCNView { clean?.scnView ?? SCNView() }

  var cleanRecorder: CleanRecorder? {
    get { clean?.cleanRecorder }
    set { clean?.cleanRecorder = newValue }
  }

  var cleanPixelBuffer: CVPixelBuffer? { clean?.cleanPixelBuffer }

  var recorder: Recorder? { clean?.cleanRecorder }

  var videoRecording: VideoRecording? {
    get { cleanVideoRecording }
    set { cleanVideoRecording = newValue }
  }

  var cleanVideoRecording: VideoRecording? {
    get { clean?.cleanVideoRecording }
    set { clean?.cleanVideoRecording = newValue }
  }

  weak var clean: CleanRecordable?

  init(clean: CleanRecordable) { self.clean = clean }
}
