//
//  InternalRecorder.swift
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
import SceneKit

extension InternalRecorder {
    
    enum Error: Swift.Error {
        
        case metalLayer
        
        case eaglContext
        
        case simulator
        
        case pixelBuffer(errorCode: CVReturn)
        
        case pixelBufferFactory
    }
}

final class InternalRecorder {
    
    let sceneView: SCNView
    
    let queue: DispatchQueue
    
    let photoQueue: DispatchQueue
    
    let synchronizationQueue: DispatchQueue
    
    let api: API
    
    private var _filters: [Filter] = []
    
    private var _hasPixelBufferConsumers: Bool = false
    
    private var _hasAudioSampleBufferConsumers: Bool = false
    
    private lazy var _pixelBufferProducer: PixelBufferProducer = api.makePixelBufferProducer()
    
    private lazy var _pixelBufferPool: CVPixelBufferPool = {
        var unmanagedPixelBufferPool: CVPixelBufferPool?
        let errorCode = CVPixelBufferPoolCreate(nil,
                                                nil,
                                                pixelBufferProducer.recommendedPixelBufferAttributes as CFDictionary,
                                                &unmanagedPixelBufferPool)
        
        guard errorCode == kCVReturnSuccess, let pixelBufferPool = unmanagedPixelBufferPool else {
            fatalError("CVPixelBufferPoolCreate Error: \(errorCode)")
        }
        
        return pixelBufferPool
    }()
    
    var pixelBufferConsumers = [(Weak<PixelBufferConsumer>, DispatchQueue)]() {
        didSet {
            let isEmpty = pixelBufferConsumers.isEmpty
            hasPixelBufferConsumers = !isEmpty
            isEmpty ? pixelBufferProducer.stopWriting() : pixelBufferProducer.startWriting()
        }
    }
    
    var audioSampleBufferConsumers = [(Weak<AudioSampleBufferConsumer>, DispatchQueue)]() {
        didSet {
            hasAudioSampleBufferConsumers = !audioSampleBufferConsumers.isEmpty
        }
    }
    
    public init(_ sceneView: SCNView) throws {
        self.sceneView = sceneView
        
        queue = DispatchQueue(label: "Recorder.DispatchQueue", qos: .userInitiated)
        photoQueue = DispatchQueue(label: "SCNRecorder.Photo.DispatchQueue", qos: .userInitiated)
        synchronizationQueue = DispatchQueue(label: "Recorder.SynchronizationQueue", qos: .userInitiated)
        
        switch sceneView.renderingAPI {
        case .metal:
            #if !targetEnvironment(simulator)
            guard let metalLayer = sceneView.layer as? CAMetalRecorderLayer else {
                throw Error.metalLayer
            }
            api = .metal(metalLayer)
            #else
            throw Error.simulator
            #endif
        case .openGLES2:
            guard let eaglContext = sceneView.eaglContext else {
                throw Error.eaglContext
            }
            api = .openGLES2(eaglContext)
        }
    }
}

extension InternalRecorder: Recorder {
    
    public static let defaultTimeScale: CMTimeScale = 600
    
    var filters: [Filter] {
        get {
            var filters = [Filter]()
            synchronizationQueue.sync {
                filters = self._filters
            }
            return filters
        }
        set {
            synchronizationQueue.async {
                self._filters = newValue
            }
        }
    }
    
    func createVideoRecording(to url: URL,
                              fileType: AVFileType = .mov,
                              timeScale: CMTimeScale = defaultTimeScale) throws -> VideoRecording {
        
        let videoRecorder = try VideoRecorder(url: url,
                                              fileType: fileType,
                                              videoSettings: pixelBufferProducer.recommendedVideoSettings,
                                              videoSourceFormatHint: nil,
                                              audioSettings: [:],
                                              audioSourceFormatHint: nil,
                                              timeScale: timeScale)
        
        videoRecorder.onFinalState = { [weak videoRecorder, weak self] in
            guard let videoRecorder = videoRecorder else {
                return
            }
            self?.removePixelBufferConsumer(videoRecorder)
        }
        
        addPixelBufferConsumer(videoRecorder, queue: videoRecorder.queue)
        addAudioSampleBufferConsumer(videoRecorder, queue: videoRecorder.queue)
        
        return videoRecorder.makeRecording()
    }
    
    func takePhoto(scale: CGFloat,
                   orientation: UIImage.Orientation,
                   completionHandler handler: @escaping (UIImage) -> Void) {
        
        addPixelBufferConsumer(ImageRecorder.takeUIImage(scale: scale,
                                                         orientation: orientation,
                                                         context: pixelBufferProducer.context,
                                                         completionHandler: handler),
                               queue: photoQueue)
    }
    
    func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) {
        
        addPixelBufferConsumer(ImageRecorder.takeCIImage(completionHandler: handler),
                               queue: photoQueue)
    }
    
    func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
        addPixelBufferConsumer(ImageRecorder.takePixelBuffer(completionHandler: handler),
                               queue: photoQueue)
    }
}

extension InternalRecorder {
    
    func addPixelBufferConsumer(_ pixelBufferConsumer: PixelBufferConsumer,
                                queue: DispatchQueue) {
        
        self.queue.async { [weak self] in
            self?.pixelBufferConsumers.append((Weak(pixelBufferConsumer), queue))
        }
    }
    
    func removePixelBufferConsumer(_ pixelBufferConsumer: PixelBufferConsumer) {
        self.queue.async { [weak self] in
            guard let `self` = self else { return }
            self.pixelBufferConsumers = self.pixelBufferConsumers.filter({ $0.0.get() !== pixelBufferConsumer })
        }
    }
    
    func addAudioSampleBufferConsumer(_ audioSampleBufferConsumer: AudioSampleBufferConsumer,
                                      queue: DispatchQueue) {
        
        self.queue.async { [weak self] in
            self?.audioSampleBufferConsumers.append((Weak(audioSampleBufferConsumer), queue))
        }
    }
}

extension InternalRecorder {
    
    var hasPixelBufferConsumers: Bool {
        get {
            var hasPixelBufferConsumers = false
            synchronizationQueue.sync {
                hasPixelBufferConsumers = self._hasPixelBufferConsumers
            }
            return hasPixelBufferConsumers
        }
        set {
            synchronizationQueue.async {
                self._hasPixelBufferConsumers = newValue
            }
        }
    }
    
    var hasAudioSampleBufferConsumers: Bool {
        get {
            var hasAudioSampleBufferConsumers = false
            synchronizationQueue.sync {
                hasAudioSampleBufferConsumers = self._hasAudioSampleBufferConsumers
            }
            return hasAudioSampleBufferConsumers
        }
        set {
            synchronizationQueue.async {
                self._hasAudioSampleBufferConsumers = newValue
            }
        }
    }
    
    func preparePixelBufferComponents() {
        synchronizationQueue.async {
            _ = self._pixelBufferProducer
            _ = self._pixelBufferPool
        }
    }
    
    var pixelBufferProducer: PixelBufferProducer {
        var pixelBufferProducer: PixelBufferProducer!
        synchronizationQueue.sync {
            pixelBufferProducer = self._pixelBufferProducer
        }
        return pixelBufferProducer
    }
    
    var pixelBufferPool: CVPixelBufferPool {
        var pixelBufferPool: CVPixelBufferPool!
        synchronizationQueue.sync {
            pixelBufferPool = self._pixelBufferPool
        }
        return pixelBufferPool
    }
}

extension InternalRecorder {
    
    func producePixelBuffer(at time: TimeInterval) {
        guard hasPixelBufferConsumers else {
            preparePixelBufferComponents()
            return
        }
        
        var unmanagedPixelBuffer: CVPixelBuffer?
        let result = CVPixelBufferPoolCreatePixelBuffer(nil,
                                                        pixelBufferPool,
                                                        &unmanagedPixelBuffer)
        
        guard result == kCVReturnSuccess, var pixelBuffer = unmanagedPixelBuffer else {
            // TODO: Handle error
            return
        }
        
        do {
            try pixelBufferProducer.writeIn(pixelBuffer: &pixelBuffer)
            try applyFilters(to: &pixelBuffer)
            
            queue.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.pixelBufferConsumers = self.pixelBufferConsumers.filter({ $0.0.get() != nil })
                self.pixelBufferConsumers.forEach({ (consumer, queue) in
                    queue.async {
                        consumer.get()?.setPixelBuffer(pixelBuffer, at: time)
                    }
                })
            }
        }
        catch {
            // TODO: Handle error
        }
    }
    
    func produceAudioSampleBuffer(_ audioSampleBuffer: CMSampleBuffer) {
        guard hasAudioSampleBufferConsumers else {
            return
        }
        
        queue.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.audioSampleBufferConsumers = self.audioSampleBufferConsumers.filter({ $0.0.get() != nil })
            self.audioSampleBufferConsumers.forEach({ (consumer, queue) in
                queue.async {
                    consumer.get()?.setAudioSampleBuffer(audioSampleBuffer)
                }
            })
        }
    }
}

extension InternalRecorder {
    
    func applyFilters(to pixelBuffer: inout CVPixelBuffer) throws {
        
        guard !filters.isEmpty else {
            return
        }
        
        var image = CIImage(cvPixelBuffer: pixelBuffer)
        for filter in filters {
            let ciFilter = try filter.makeCIFilter(for: image)
            
            guard let outputImage = ciFilter.outputImage else {
                throw Filter.Error.noOutput
            }
            
            image = outputImage
        }
        
        let attachments = CVBufferGetAttachments(pixelBuffer, .shouldPropagate)!
        let colorSpace = CVImageBufferCreateColorSpaceFromAttachments(attachments)!.takeRetainedValue()
        pixelBufferProducer.context.render(image, to: pixelBuffer, bounds: image.extent, colorSpace: colorSpace)
    }
}
