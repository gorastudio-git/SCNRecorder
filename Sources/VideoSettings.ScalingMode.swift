//
//  VideoSettings.ScalingMode.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 20.07.2020.
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

public extension VideoSettings {

  enum ScalingMode {

    /// Crop to remove edge processing region.
    /// Preserve aspect ratio of cropped source by reducing specified width or height if necessary.
    /// Will not scale a small source up to larger dimensions.
//    case fit

    /// Crop to remove edge processing region.
    /// Scale remainder to destination area.
    /// Does not preserve aspect ratio.
    case resize

    /// Preserve aspect ratio of the source, and fill remaining areas with black to fit destination dimensions.
    case resizeAspect

    /// Preserve aspect ratio of the source, and crop picture to fit destination dimensions.
    case resizeAspectFill
  }
}

extension VideoSettings.ScalingMode {

  var avScalingMode: String {
    switch self {
//    case .fit: return AVVideoScalingModeFit
    case .resize: return AVVideoScalingModeResize
    case .resizeAspect: return AVVideoScalingModeResizeAspect
    case .resizeAspectFill: return AVVideoScalingModeResizeAspectFill
    }
  }
}
