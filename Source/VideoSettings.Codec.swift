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
    
    case hevc
    
    case h264(compressionProperties: H264CompressionProperties = H264CompressionProperties())
    
    case jpeg
  }
}

extension VideoSettings.Codec {
  
  var avCodec: AVVideoCodecType {
    switch self {
    case .hevc: return .hevc
    case .h264: return .h264
    case .jpeg: return .jpeg
    }
  }
}

public extension VideoSettings {

  struct H264CompressionProperties {

    public enum ProfileLevel: RawRepresentable {
      case baseline30
      case baseline31
      case baseline41
      case baselineAutoLevel

      case main30
      case main31
      case main32
      case main41
      case mainAutoLevel

      case high40
      case high41
      case highAutoLevel

      public init?(rawValue: String) {
        switch rawValue {
        case AVVideoProfileLevelH264Baseline30: self = .baseline30
        case AVVideoProfileLevelH264Baseline31: self = .baseline31
        case AVVideoProfileLevelH264Baseline41: self = .baseline41
        case AVVideoProfileLevelH264BaselineAutoLevel: self = .baselineAutoLevel

        case AVVideoProfileLevelH264Main30: self = .main30
        case AVVideoProfileLevelH264Main31: self = .main31
        case AVVideoProfileLevelH264Main32: self = .main32
        case AVVideoProfileLevelH264Main41: self = .main41
        case AVVideoProfileLevelH264MainAutoLevel: self = .mainAutoLevel

        case AVVideoProfileLevelH264High40: self = .high40
        case AVVideoProfileLevelH264High41: self = .high41
        case AVVideoProfileLevelH264HighAutoLevel: self = .highAutoLevel

        default: return nil
        }
      }

      public var rawValue: String {
        switch self {
        case .baseline30: return AVVideoProfileLevelH264Baseline30
        case .baseline31: return AVVideoProfileLevelH264Baseline31
        case .baseline41: return AVVideoProfileLevelH264Baseline41
        case .baselineAutoLevel: return AVVideoProfileLevelH264BaselineAutoLevel

        case .main30: return AVVideoProfileLevelH264Main30
        case .main31: return AVVideoProfileLevelH264Main31
        case .main32: return AVVideoProfileLevelH264Main32
        case .main41: return AVVideoProfileLevelH264Main41
        case .mainAutoLevel: return AVVideoProfileLevelH264MainAutoLevel

        case .high40: return AVVideoProfileLevelH264High40
        case .high41: return AVVideoProfileLevelH264High41
        case .highAutoLevel: return AVVideoProfileLevelH264HighAutoLevel
        }
      }
    }

    public enum EntropyMode: RawRepresentable {

      case cavlc

      case cabac

      public init?(rawValue: String) {
        switch rawValue {
        case AVVideoH264EntropyModeCAVLC: self = .cavlc
        case AVVideoH264EntropyModeCABAC: self = .cabac
        default: return nil
        }
      }

      public var rawValue: String {
        switch self {
        case .cavlc: return AVVideoH264EntropyModeCAVLC
        case .cabac: return AVVideoH264EntropyModeCABAC
        }
      }
    }

    public var averageBitRate: Int?

    public var maxKeyFrameInterval: Int?

    public var maxKeyFrameIntervalDuration: TimeInterval?

    public var allowFrameReordering: Bool?

    public var profileLevel: ProfileLevel?

    public var entropyMode: EntropyMode?

    public var expectedSourceFrameRate: Int?

    public var averageNonDroppableFrameRate: Int?

    public var rawSettings: [String: Any] = [:]

    public init(
      averageBitRate: Int? = nil,
      maxKeyFrameInterval: Int? = nil,
      maxKeyFrameIntervalDuration: TimeInterval? = nil,
      allowFrameReordering: Bool? = nil,
      profileLevel: ProfileLevel? = nil,
      entropyMode: EntropyMode? = nil,
      expectedSourceFrameRate: Int? = nil,
      averageNonDroppableFrameRate: Int? = nil
    ) {
      self.averageBitRate = averageBitRate
      self.maxKeyFrameInterval = maxKeyFrameInterval
      self.maxKeyFrameIntervalDuration = maxKeyFrameIntervalDuration
      self.allowFrameReordering = allowFrameReordering
      self.profileLevel = profileLevel
      self.entropyMode = entropyMode
      self.expectedSourceFrameRate = expectedSourceFrameRate
      self.averageNonDroppableFrameRate = averageNonDroppableFrameRate
    }

    var settings: [String: Any] {
      rawSettings.merging(
        ([
          AVVideoAverageBitRateKey: averageBitRate,
          AVVideoMaxKeyFrameIntervalKey: maxKeyFrameInterval,
          AVVideoMaxKeyFrameIntervalDurationKey: maxKeyFrameIntervalDuration,
          AVVideoAllowFrameReorderingKey: allowFrameReordering,
          AVVideoProfileLevelKey: profileLevel?.rawValue,
          AVVideoH264EntropyModeKey: entropyMode?.rawValue,
          AVVideoExpectedSourceFrameRateKey: expectedSourceFrameRate,
          AVVideoAverageNonDroppableFrameRateKey: averageNonDroppableFrameRate
        ] as [String: Any?]).compactMapValues({ $0 }),
        uniquingKeysWith: { raw, _ in raw }
      )
    }
  }
}
