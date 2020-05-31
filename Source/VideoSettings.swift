//
//  VideoSettings.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 26.04.2020.
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

public struct VideoSettings {

  /// The type of the output video file.
  var fileType: FileType = .mov

  /// The codec used to encode the output video.
  var codec: Codec = .h264

  /// The size of the output video.
  ///
  /// If `.zero` the size of the video source will be used.
  /// Look at `ScalingMode` for possible scaling modes.
  var size: CGSize = .zero

  /// Defines the region within the video dimensions that will be displayed during playback
  ///
  /// If no clean aperture region is specified, the entire frame will be displayed during playback.
  var cleanApreture: CleanApreture?

  var scalingMode: ScalingMode
}

extension VideoSettings {

  enum Codec {

    case hevc

    case h264

    case jpeg
  }

  enum ScalingMode {

    case fit

    case resize

    case resizeAspect

    case resizeAspectFill
  }

  /**
   AVVideoCleanApertureWidthKey and AVVideoCleanApertureHeightKey define a
   clean rectangle which is centered on the video frame.  To offset this
   rectangle from center, use AVVideoCleanApertureHorizontalOffsetKey and
   AVVideoCleanApertureVerticalOffsetKey.  A positive value for
   AVVideoCleanApertureHorizontalOffsetKey moves the clean aperture region to the
   right, and a positive value for AVVideoCleanApertureVerticalOffsetKey moves the clean aperture region down.
   */

  struct CleanApreture {

    var size: CGSize

    var offset: CGPoint
  }
}
