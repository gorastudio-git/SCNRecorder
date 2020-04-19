//
//  InternalRecorder.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 11/03/2019.
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

extension InternalRecorder {

  enum Error: Swift.Error {

    case recordableLayer

    case eaglContext

    case metalSimulator

    case pixelBuffer(errorCode: CVReturn)

    case pixelBufferFactory

    case unknownAPI
  }
}

final class InternalRecorder {

  public static let defaultTimeScale: CMTimeScale = 600

  let queue: DispatchQueue

  var filters = Atomic([Filter]())

  var pixelBufferConsumers = Atomic([PixelBufferConsumer]())

  var audioSampleBufferConsumers = Atomic([AudioSampleBufferConsumer]())

  let pixelBufferProducer: PixelBufferProducer

  let pixelBufferPoolFactory = PixelBufferPoolFactory()

  let error = Property<Swift.Error?>(nil)

  public init(_ recordableView: RecordableView, queue: DispatchQueue) throws {
    self.queue = queue

    switch recordableView.api {
    case .metal:
      #if !targetEnvironment(simulator)
      guard let recordableLayer = recordableView.recordableLayer else { throw Error.recordableLayer }
      self.pixelBufferProducer = MetalPixelBufferProducer(recordableLayer: recordableLayer)
      #else // !targetEnvironment(simulator)
      throw Error.metalSimulator
      #endif // !targetEnvironment(simulator)
    case .openGLES:
      guard let eaglContext = recordableView.eaglContext else { throw Error.eaglContext }
      self.pixelBufferProducer = EAGLPixelBufferProducer(eaglContext: eaglContext)
    case .unknown: throw Error.unknownAPI
    }
  }
}

extension InternalRecorder {

  func makeVideoRecording(
    to url: URL,
    fileType: AVFileType = .mov,
    timeScale: CMTimeScale = defaultTimeScale
  ) throws -> SCNVideoRecording {

    let videoConfiguration = VideoRecorder.VideoConfiguration.Builder()
    videoConfiguration.videoSettings = pixelBufferProducer.recommendedVideoSettings
    videoConfiguration.transform = pixelBufferProducer.transform

    let audioConfiguration = VideoRecorder.AudioConfiguration.Builder()

    let videoRecorder = try VideoRecorder(
      url: url,
      fileType: fileType,
      videoConfiguration: videoConfiguration.build(),
      audioConfiguration: audioConfiguration.build(),
      timeScale: timeScale,
      queue: queue
    )

    videoRecorder.onFinalState = { [weak self] in
      self?.removePixelBufferConsumer($0)
      self?.removeAudioSampleBufferConsumer($0)
    }

    addPixelBufferConsumer(videoRecorder)
    addAudioSampleBufferConsumer(videoRecorder)
    return videoRecorder.makeRecording()
  }

  func takePhoto(
    scale: CGFloat,
    orientation: UIImage.Orientation,
    completionHandler handler: @escaping (UIImage) -> Void
  ) {
    addPixelBufferConsumer(
      ImageRecorder.takeUIImage(
        scale: scale,
        orientation: orientation,
        transform: pixelBufferProducer.transform,
        context: pixelBufferProducer.context,
        completionHandler: { [weak self] in
          self?.removePixelBufferConsumer($0)
          handler($1)
        }
      )
    )
  }

  func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) {
    addPixelBufferConsumer(
      ImageRecorder.takeCIImage(
        transform: pixelBufferProducer.transform,
        context: pixelBufferProducer.context,
        completionHandler: { [weak self] in
          self?.removePixelBufferConsumer($0)
          handler($1)
        }
      )
    )
  }

  func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
    addPixelBufferConsumer(
      ImageRecorder.takePixelBuffer(
        transform: pixelBufferProducer.transform,
        context: pixelBufferProducer.context,
        completionHandler: { [weak self] in
          self?.removePixelBufferConsumer($0)
          handler($1)
        }
      )
    )
  }
}

extension InternalRecorder {

  func addPixelBufferConsumer(_ pixelBufferConsumer: PixelBufferConsumer) {
    pixelBufferConsumers.modify {
      $0.append(pixelBufferConsumer)
      if $0.count == 1 { pixelBufferProducer.startWriting() }
    }
  }

  func removePixelBufferConsumer(_ pixelBufferConsumer: PixelBufferConsumer) {
    pixelBufferConsumers.modify {
      $0 = $0.filter { $0 !== pixelBufferConsumer }
      if $0.count == 0 { pixelBufferProducer.stopWriting() }
    }
  }

  func addAudioSampleBufferConsumer(_ audioSampleBufferConsumer: AudioSampleBufferConsumer) {
    audioSampleBufferConsumers.modify { $0.append(audioSampleBufferConsumer)}
  }

  func removeAudioSampleBufferConsumer(_ audioSampleBufferConsumer: AudioSampleBufferConsumer) {
    audioSampleBufferConsumers.modify { $0 = $0.filter { $0 !== audioSampleBufferConsumer }}
  }
}

extension InternalRecorder {

  func producePixelBuffer(at time: TimeInterval) {
    guard !pixelBufferConsumers.value.isEmpty else { return }

    do {
      let attributes = pixelBufferProducer.recommendedPixelBufferAttributes
      let pixelBufferPool = try pixelBufferPoolFactory.makeWithAttributes(attributes)
      var pixelBuffer = try CVPixelBuffer.makeWithPixelBufferPool(pixelBufferPool)
      try pixelBufferProducer.writeIn(pixelBuffer: &pixelBuffer)
      try pixelBuffer.applyFilters(filters.value, using: pixelBufferProducer.context)

      queue.async { [weak self] in
        guard let this = self else { return }
        let consumers = this.pixelBufferConsumers.value
        let shouldCopy = consumers.count > 1

        consumers.forEach {
          do {
            $0.appendPixelBuffer(
              shouldCopy ? try pixelBuffer.copyWithPixelBufferPool(pixelBufferPool) : pixelBuffer,
              at: time
            )
          }
          catch {
            this.error.value = error
          }
        }
      }
    }
    catch {
      self.error.value = error
    }
  }

  func produceAudioSampleBuffer(_ audioSampleBuffer: CMSampleBuffer) {
    guard !audioSampleBufferConsumers.value.isEmpty else { return }

    queue.async { [weak self] in
      guard let this = self else { return }
      this.audioSampleBufferConsumers.value.forEach {
        $0.appendAudioSampleBuffer(audioSampleBuffer)
      }
    }
  }
}
