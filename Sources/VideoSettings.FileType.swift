//
//  VideoSettings.FileType.swift
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

public extension VideoSettings {

  enum FileType: CaseIterable {

    /// A UTI for the QuickTime movie file format.
    ///
    /// The value of this UTI is @"com.apple.quicktime-movie".
    ///
    /// Files are identified with the .mov and .qt extensions.
    case mov

    /// A UTI for the MPEG-4 file format.
    ///
    /// The value of this UTI is @"public.mpeg-4".
    ///
    /// Files are identified with the .mp4 extension.
    case mp4

    /// A UTI for video container format very similar to the MP4 format.
    ///
    /// The value of this UTI is @"com.apple.m4v-video".
    ///
    /// Files are identified with the .m4v extension.
    case m4v

    /// A UTI for the 3GPP file format.
    ///
    /// The value of this UTI is @"public.3gpp".
    ///
    /// Files are identified with the .3gp, .3gpp, and .sdv extensions.
    case mobile3GPP
  }
}

extension VideoSettings.FileType {

  var avFileType: AVFileType {
    switch self {
    case .mov: return .mov
    case .mp4: return .mp4
    case .m4v: return .m4v
    case .mobile3GPP: return .mobile3GPP
    }
  }

  var fileExtension: String {
    switch self {
    case .mov: return "mov"
    case .mp4: return "mp4"
    case .m4v: return "m4v"
    case .mobile3GPP: return "3gp"
    }
  }
}
