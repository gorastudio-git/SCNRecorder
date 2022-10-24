//
//  CleanRecorder.VideoInput.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
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

extension CleanRecorder {

  final class VideoInput<T: CleanRecordable>: MediaSessionInput_PixelBufferVideo, TimeScalable {

    weak var cleanRecordable: T?

    let timeScale: CMTimeScale

    let queue: DispatchQueue

    var size: CGSize {
      guard let buffer = cleanRecordable?.cleanPixelBuffer else { return .zero }
      return CGSize(
        width: CVPixelBufferGetWidth(buffer),
        height: CVPixelBufferGetHeight(buffer)
      )
    }

    var videoColorProperties: [String: String]? { nil }

    var videoTransform: CGAffineTransform { .identity }

    var imageOrientation: UIImage.Orientation { .up }

    lazy var pixelBufferPoolFactory = PixelBufferPoolFactory.getWeaklyShared()

    let context: CIContext = MTLCreateSystemDefaultDevice()
      .map({ CIContext(mtlDevice: $0 )}) ?? CIContext()

    var output: ((CVBuffer, CMTime) -> Void)?

    @UnfairAtomic var started: Bool = false

    init(cleanRecordable: T, timeScale: CMTimeScale, queue: DispatchQueue) {
      self.cleanRecordable = cleanRecordable
      self.timeScale = timeScale
      self.queue = queue
    }

    func start() { started = true }

    func stop() { started = false }

    func render(atTime time: TimeInterval) throws {
      guard started, let output = output else { return }
      guard let pixelBuffer = cleanRecordable?.cleanPixelBuffer else { return }

      let time = timeFromSeconds(time)
      queue.async { output(pixelBuffer, time) }
    }
  }
}
