//
//  TimeScalable.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 19.04.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import AVFoundation

protocol TimeScalable {

  var timeScale: CMTimeScale { get }
}

extension TimeScalable {

  func timeFromSeconds(_ seconds: TimeInterval) -> CMTime {
    return CMTime(seconds: seconds, preferredTimescale: timeScale)
  }
}
