//
//  MediaSessionInput.swift
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
import UIKit


internal typealias MediaSessionInput_SampleBufferAudio = AudioMediaSessionInput & SampleBufferInput
internal typealias MediaSessionInput_SampleBufferVideo = VideoMediaSessionInput & SampleBufferInput
internal typealias MediaSessionInput_PixelBufferVideo = VideoMediaSessionInput & BufferInput


internal
protocol MediaSessionInput {

  func start()

  func stop()
}

internal
protocol AudioMediaSessionInput: MediaSessionInput {

  func recommendedAudioSettingsForAssetWriter(
    writingTo outputFileType: AVFileType
  ) -> [String: Any]
}

internal
protocol VideoMediaSessionInput: MediaSessionInput {

  var size: CGSize { get }

  var videoColorProperties: [String: String]? { get }

  var videoTransform: CGAffineTransform { get }

  var imageOrientation: UIImage.Orientation { get }
}

internal
protocol SampleBufferInput: AnyObject {

  var output: ((CMSampleBuffer) -> Void)? { get set }
}

internal
protocol BufferInput: AnyObject {

  var output: ((CVBuffer, CMTime) -> Void)? { get set }
}
