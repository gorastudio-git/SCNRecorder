//
//  VideoSettings.Codec.swift
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

  enum Codec {

    public static func hevc(
      averageBitRate: Int? = nil,
      maxKeyFrameInterval: Int? = nil,
      maxKeyFrameIntervalDuration: TimeInterval? = nil,
      allowFrameReordering: Bool? = nil,
      expectedSourceFrameRate: Int? = nil,
      averageNonDroppableFrameRate: Int? = nil,
      profileLevel: HEVCCompressionProperties.ProfileLevel? = nil
    ) -> Codec {
      .hevc(.init(
        averageBitRate: averageBitRate,
        maxKeyFrameInterval: maxKeyFrameInterval,
        maxKeyFrameIntervalDuration: maxKeyFrameIntervalDuration,
        allowFrameReordering: allowFrameReordering,
        expectedSourceFrameRate: expectedSourceFrameRate,
        averageNonDroppableFrameRate: averageNonDroppableFrameRate,
        profileLevel: profileLevel
      ))
    }

    case hevc(_ compressionProperties: HEVCCompressionProperties)

    @available(iOS 13.0, *)
    public static func hevcWithAlpha(
      averageBitRate: Int? = nil,
      maxKeyFrameInterval: Int? = nil,
      maxKeyFrameIntervalDuration: TimeInterval? = nil,
      allowFrameReordering: Bool? = nil,
      expectedSourceFrameRate: Int? = nil,
      averageNonDroppableFrameRate: Int? = nil,
      profileLevel: HEVCCompressionProperties.ProfileLevel? = nil
    ) -> Codec {
      .hevcWithAlpha(.init(
        averageBitRate: averageBitRate,
        maxKeyFrameInterval: maxKeyFrameInterval,
        maxKeyFrameIntervalDuration: maxKeyFrameIntervalDuration,
        allowFrameReordering: allowFrameReordering,
        expectedSourceFrameRate: expectedSourceFrameRate,
        averageNonDroppableFrameRate: averageNonDroppableFrameRate,
        profileLevel: profileLevel
      ))
    }

    case hevcWithAlpha(_ compressionProperties: HEVCCompressionProperties)

    public static func h264(
      averageBitRate: Int? = nil,
      maxKeyFrameInterval: Int? = nil,
      maxKeyFrameIntervalDuration: TimeInterval? = nil,
      allowFrameReordering: Bool? = nil,
      expectedSourceFrameRate: Int? = nil,
      averageNonDroppableFrameRate: Int? = nil,
      profileLevel: H264CompressionProperties.ProfileLevel? = nil,
      entropyMode: H264CompressionProperties.EntropyMode? = nil
    ) -> Codec {
      .h264(.init(
        averageBitRate: averageBitRate,
        maxKeyFrameInterval: maxKeyFrameInterval,
        maxKeyFrameIntervalDuration: maxKeyFrameIntervalDuration,
        allowFrameReordering: allowFrameReordering,
        expectedSourceFrameRate: expectedSourceFrameRate,
        averageNonDroppableFrameRate: averageNonDroppableFrameRate,
        profileLevel: profileLevel,
        entropyMode: entropyMode
      ))
    }

    case h264(_ compressionProperties: H264CompressionProperties)

    public static func jpeg(
      averageBitRate: Int? = nil,
      maxKeyFrameInterval: Int? = nil,
      maxKeyFrameIntervalDuration: TimeInterval? = nil,
      allowFrameReordering: Bool? = nil,
      expectedSourceFrameRate: Int? = nil,
      averageNonDroppableFrameRate: Int? = nil
    ) -> Codec {
      .jpeg(.init(
        averageBitRate: averageBitRate,
        maxKeyFrameInterval: maxKeyFrameInterval,
        maxKeyFrameIntervalDuration: maxKeyFrameIntervalDuration,
        allowFrameReordering: allowFrameReordering,
        expectedSourceFrameRate: expectedSourceFrameRate,
        averageNonDroppableFrameRate: averageNonDroppableFrameRate
      ))
    }

    case jpeg(_ compressionProperties: JPEGCompressionProperties)

    var _compressionProperties: CompressionProperties {
      switch self {
      case .hevc(let compressionProperties as CompressionProperties),
           .hevcWithAlpha(let compressionProperties as CompressionProperties),
           .h264(let compressionProperties as CompressionProperties),
           .jpeg(let compressionProperties as CompressionProperties):
        return compressionProperties
      }
    }

    public var compressionProperties: [String: Any]? {
      _compressionProperties.settings
    }
  }
}

public extension VideoSettings.Codec {

  var avCodec: AVVideoCodecType {
    switch self {
    case .hevc:
      return .hevc
    case .hevcWithAlpha:
      if #available(iOS 13.0, *) { return .hevcWithAlpha }
      else { return .hevc }
    case .h264:
      return .h264
    case .jpeg:
      return .jpeg
    }
  }
}
