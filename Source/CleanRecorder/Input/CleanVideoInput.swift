//
//  CleanVideoInput.swift
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
import AVFoundation
import SceneKit

final class CleanVideoInput: VideoInput, BufferInput, TimeScalable {

  let cleanRecordable: CleanRecordable

  let timeScale: CMTimeScale

  var recommendedVideoSettings: [String: Any] {
    guard let buffer = cleanRecordable.cleanPixelBuffer else { return [:] }
    return [
      AVVideoWidthKey: buffer.width,
      AVVideoHeightKey: buffer.height,
      AVVideoCodecKey: AVVideoCodecType.h264,
    ]
  }

  var context: CIContext { CIContext() }

  weak var delegate: MediaRecorderInputDelegate?

  @UnfairAtomic var started: Bool = false

  init(cleanRecordable: CleanRecordable, timeScale: CMTimeScale) {
    self.cleanRecordable = cleanRecordable
    self.timeScale = timeScale
  }

  func start() { started = true }

  func renderer(
    _ renderer: SCNSceneRenderer,
    didRenderScene scene: SCNScene,
    atTime time: TimeInterval
  ) throws {
    guard started else { return }
    guard let pixelBuffer = cleanRecordable.cleanPixelBuffer else { return }
    bufferDelegate?.input(self, didOutput: pixelBuffer, at: timeFromSeconds(time))
  }

  func stop() { started = false }
}
