//
//  PixelBufferOutput.swift
//  SCNRecorder
//
//  Created by VG on 06.10.2020.
//

import Foundation
import AVFoundation

final public class PixelBufferOutput {

  final class Weak: MediaSession.Output.Video {

    weak var output: PixelBufferOutput?

    var deinitHandler: ((Weak) -> Void)?

    init(output: PixelBufferOutput, deinitHandler: @escaping (Weak) -> Void) {
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

  var handler: (CVPixelBuffer, CMTime) -> Void

  init(handler: @escaping (CVPixelBuffer, CMTime) -> Void) {
    self.handler = handler
  }
}

extension PixelBufferOutput: MediaSession.Output.Video {

  func appendVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
    guard let imageBuffer: CVImageBuffer = {
      if #available(iOS 13.0, *) {
        return sampleBuffer.imageBuffer
      } else {
        return CMSampleBufferGetImageBuffer(sampleBuffer)
      }
    }() else { return }

    let time: CMTime
    if #available(iOS 13.0, *) {
      time = sampleBuffer.presentationTimeStamp
    } else {
      time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    }

    handler(imageBuffer, time)
  }

  func appendVideoBuffer(_ buffer: CVBuffer, at time: CMTime) {
    handler(buffer, time)
  }
}
