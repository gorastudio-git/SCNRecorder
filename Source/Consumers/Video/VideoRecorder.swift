//
//  VideoRecorder.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 11/03/2019.
//  Copyright (c) 2019 GORA Studio. https://gora.studio
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

extension VideoRecorder {
    
    enum Error: Swift.Error {
        
        case fileAlreadyExists
        
        case notStarted
        
        case wrongState
    }
}

final class VideoRecorder {
    
    let timeScale: CMTimeScale
    
    let assetWriter: AVAssetWriter
    
    let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    let audioAssetWriterInput: AVAssetWriterInput?
    
    let queue: DispatchQueue
    
    var state: State = .ready {
        didSet {
            recording?.state = state.recordingState
            
            if state.isFinal {
                onFinalState()
            }
        }
    }
    
    var duration: TimeInterval = 0.0 {
        didSet {
            recording?.duration = duration
        }
    }
    
    var startSeconds: TimeInterval = 0.0
    
    weak var recording: Recording?
    
    var onFinalState: () -> Void = { }
    
    init(url: URL,
         fileType: AVFileType,
         videoSettings: [String: Any],
         videoSourceFormatHint: CMFormatDescription?,
         audioSettings: [String: Any],
         audioSourceFormatHint: CMFormatDescription?,
         timeScale: CMTimeScale,
         queue: DispatchQueue = DispatchQueue.init(label: "VideoRecorder", qos: .userInitiated)) throws {
        
        self.timeScale = timeScale
        assetWriter = try AVAssetWriter(url: url, fileType: fileType)
        
        let videoAssetWriterInput = AVAssetWriterInput(mediaType: .video,
                                                       outputSettings: videoSettings,
                                                       sourceFormatHint: nil)
        videoAssetWriterInput.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(videoAssetWriterInput) {
            assetWriter.add(videoAssetWriterInput)
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoAssetWriterInput,
                                                                      sourcePixelBufferAttributes: nil)
        }
        else {
            pixelBufferAdaptor = nil
        }
        
        let audioAssetWriterInput = AVAssetWriterInput(mediaType: .audio,
                                                       outputSettings: nil,
                                                       sourceFormatHint: audioSourceFormatHint)
        audioAssetWriterInput.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(audioAssetWriterInput) {
            assetWriter.add(audioAssetWriterInput)
            self.audioAssetWriterInput = audioAssetWriterInput
        }
        else {
            self.audioAssetWriterInput = nil
        }
        
        guard assetWriter.startWriting() else {
            throw assetWriter.error ?? Error.notStarted
        }
        
        self.queue = queue
    }
    
    deinit {
        state = state.cancel(self)
    }
}

extension VideoRecorder {
    
    func startSession(at seconds: TimeInterval) {
        startSeconds = seconds + 0.2
        assetWriter.startSession(atSourceTime: timeFromSeconds(seconds))
    }
    
    func endSession(at seconds: TimeInterval) {
        assetWriter.endSession(atSourceTime: timeFromSeconds(seconds))
    }
    
    func finishWriting(completionHandler handler: @escaping () -> Void) {
        assetWriter.finishWriting(completionHandler: handler)
    }
    
    func cancelWriting() {
        assetWriter.cancelWriting()
    }
    
    func append(_ pixelBuffer: CVPixelBuffer, withSeconds seconds: TimeInterval) {
        duration = seconds - startSeconds
        
        guard let adaptor = pixelBufferAdaptor else {
            return
        }
        
        guard adaptor.assetWriterInput.isReadyForMoreMediaData else {
            return
        }
        
        guard adaptor.append(pixelBuffer, withPresentationTime: timeFromSeconds(seconds)) else {
            return
        }
    }
    
    func append(_ sampleBuffer: CMSampleBuffer) {
        guard let input = audioAssetWriterInput else {
            return
        }
        
        guard input.isReadyForMoreMediaData else {
            return
        }
        
        guard input.append(sampleBuffer) else {
            return
        }
    }
}


extension VideoRecorder {
    
    func makeRecording() -> VideoRecording {
        let recording = Recording(videoRecorder: self)
        self.recording = recording
        return recording
    }
}

extension VideoRecorder: Controlable {
    
    func resume(onError: @escaping (Swift.Error) -> Void) {
        queue.async { [weak self] in
            do {
                guard let `self` = self else { return }
                self.state = try self.state.resume(self)
            }
            catch {
                onError(error)
            }
        }
    }
    
    func pause() {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.state = self.state.pause(self)
        }
    }
    
    func finish(completionHandler handler: @escaping () -> Void) {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.state = self.state.finish(self, completionHandler: handler)
        }
    }
    
    func cancel() {
        queue.async { [weak self] in
            guard let `self` = self else { return }
            self.state = self.state.cancel(self)
        }
    }
}

extension VideoRecorder: VideoInfoProvider {
    
    var url: URL {
        return assetWriter.outputURL
    }
    
    var fileType: AVFileType {
        return assetWriter.outputFileType
    }
}

extension VideoRecorder: PixelBufferConsumer {
    
    func setPixelBuffer(_ pixelBuffer: CVPixelBuffer, at time: TimeInterval) {
        state = state.setPixelBuffer(pixelBuffer, at: time, to: self)
    }
}

extension VideoRecorder: AudioSampleBufferConsumer {
    
    func setAudioSampleBuffer(_ audioSampleBuffer: CMSampleBuffer) {
        state = state.setAudioSampleBuffer(audioSampleBuffer, to: self)
    }
}

fileprivate extension VideoRecorder {
    
    func timeFromSeconds(_ seconds: TimeInterval) -> CMTime {
        return CMTime(seconds: seconds, preferredTimescale: timeScale)
    }
}
