//
//  RTCOutput.swift
//  SCNRecorder
//
//  Created by VG on 06.10.2020.
//

import Foundation
import AVFoundation

final public class RTCOutput {

  final class Weak: MediaSession.Output.Video {

    weak var output: RTCOutput?

    var deinitHandler: ((Weak) -> Void)?

    init(output: RTCOutput, deinitHandler: @escaping (Weak) -> Void) {
      self.output = output
      self.deinitHandler = deinitHandler
    }

    func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
      guard let output = output else {
        deinitHandler?(self)
        deinitHandler = nil
        return
      }
      output.appendVideoSampleBuffer(sampleBuffer)
    }

    func appendVideoBuffer(_ buffer: CVBuffer, at time: CMTime) {
      guard let output = output else {
        deinitHandler?(self)
        deinitHandler = nil
        return
      }
      output.appendVideoBuffer(buffer, at: time)
    }
  }

  var handler: (CVPixelBuffer) -> Void

  init(handler: @escaping (CVPixelBuffer) -> Void) {
    self.handler = handler
  }
}

extension RTCOutput: MediaSession.Output.Video {

  func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
    guard let imageBuffer: CVImageBuffer = {
      if #available(iOS 13.0, *) {
        return sampleBuffer.imageBuffer
      } else {
        return CMSampleBufferGetImageBuffer(sampleBuffer)
      }
    }() else { return }
    handler(imageBuffer)
  }

  func appendVideoBuffer(_ buffer: CVBuffer, at time: CMTime) {
    handler(buffer)
  }
}
