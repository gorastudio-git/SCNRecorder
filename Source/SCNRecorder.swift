//
//  SCNRecorder.swift
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

extension SCNRecorder {
    
    enum Error: Swift.Error {
        
        case wrongType
    }
}

public final class SCNRecorder: NSObject {
    
    public internal(set) weak var sceneView: SCNRecorder.View?
    
    weak var sceneViewDelegate: SCNSceneRendererDelegate?
    
    let recorder: InternalRecorder
    
    let audioAdapter: AudioAdapter
    
    let audioQueue = DispatchQueue(label: "SCNRecorder.AudioQueue", qos: .userInitiated)
    
    public init(_ sceneView: SceneKit.SCNView) throws {
        guard let sceneView = sceneView as? View else {
            throw Error.wrongType
        }
        
        self.sceneView = sceneView
        self.recorder = try InternalRecorder(sceneView)
        audioAdapter = AudioAdapter(queue: audioQueue, callback: { [recorder] (sampleBuffer) in
            recorder.produceAudioSampleBuffer(sampleBuffer)
        })
        
        super.init()
        sceneView.recorder = self
    }
    
    deinit {
        sceneView?.recorder = nil
    }
}

extension SCNRecorder: Recorder {
    
    public static let defaultTimeScale: CMTimeScale = InternalRecorder.defaultTimeScale
    
    public var filters: [Filter] {
        get {
            return recorder.filters
        }
        set {
            recorder.filters = newValue
        }
    }
    
    public func makeVideoRecording(to url: URL,
                                   fileType: AVFileType = .mov,
                                   timeScale: CMTimeScale = defaultTimeScale) throws -> VideoRecording {
        
        return try recorder.makeVideoRecording(to: url,
                                               fileType: fileType,
                                               timeScale: timeScale)
    }
    
    public func takePhoto(scale: CGFloat = UIScreen.main.scale,
                          orientation: UIImage.Orientation = .up,
                          completionHandler handler: @escaping (UIImage) -> Void) {
        
        recorder.takePhoto(scale: scale,
                           orientation: orientation,
                           completionHandler: handler)
    }
    
    public func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) {
        recorder.takeCoreImage(completionHandler: handler)
    }
    
    public func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
        recorder.takePixelBuffer(completionHandler: handler)
    }
}

extension SCNRecorder: SCNSceneRendererDelegate {
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        sceneViewDelegate?.renderer?(renderer, updateAtTime: time)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        sceneViewDelegate?.renderer?(renderer, didApplyAnimationsAtTime: time)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        sceneViewDelegate?.renderer?(renderer, didSimulatePhysicsAtTime: time)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
        sceneViewDelegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        sceneViewDelegate?.renderer?(renderer, willRenderScene: scene, atTime: time)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        sceneViewDelegate?.renderer?(renderer, didRenderScene: scene, atTime: time)
        recorder.producePixelBuffer(at: time)
    }
}

extension SCNRecorder {
    
    final class AudioAdapter: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
        
        typealias Callback = (_ sampleBuffer: CMSampleBuffer) -> Void
        
        let output: AVCaptureAudioDataOutput
        
        let queue: DispatchQueue
        
        let callback: Callback
        
        init(queue: DispatchQueue, callback: @escaping Callback) {
            self.queue = queue
            self.callback = callback
            output = AVCaptureAudioDataOutput()
            
            super.init()
            output.setSampleBufferDelegate(self, queue: queue)
        }
        
        @objc func captureOutput(_ output: AVCaptureOutput,
                                 didOutput sampleBuffer: CMSampleBuffer,
                                 from connection: AVCaptureConnection) {
            callback(sampleBuffer)
        }
    }
}
