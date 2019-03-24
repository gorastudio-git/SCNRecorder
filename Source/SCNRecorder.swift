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
import ARKit

public extension SCNRecorder {
    
    public enum Error: Swift.Error {
        
        case notRecordableView
    }
}

public final class SCNRecorder: NSObject {
    
    public typealias SCNView = SCNRecordableView
    
    public typealias ARSCNView = ARSCNRecordableView
    
    weak var recordableView: RecordableView?
    
    weak var delegate: AnyObject?
    
    let recorder: InternalRecorder
    
    let audioAdapter: AudioAdapter
    
    let audioQueue = DispatchQueue(label: "SCNRecorder.AudioQueue", qos: .userInitiated)
    
    public init(_ sceneView: SceneKit.SCNView) throws {
        guard let recordableView = sceneView as? RecordableView else {
            throw Error.notRecordableView
        }
        
        self.recordableView = recordableView
        self.recorder = try InternalRecorder(sceneView)
        audioAdapter = AudioAdapter(queue: audioQueue, callback: { [recorder] (sampleBuffer) in
            recorder.produceAudioSampleBuffer(sampleBuffer)
        })
        
        super.init()
        recordableView.recorder = self
    }
    
    deinit {
        recordableView?.recorder = nil
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

// MARK: - SCNSceneRendererDelegate
extension SCNRecorder: SCNSceneRendererDelegate {
    
    var sceneViewDelegate: SCNSceneRendererDelegate? {
        get {
            return delegate as? SCNSceneRendererDelegate
        }
        set {
            delegate = newValue
        }
    }
    
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

// MARK: - ARSCNViewDelegate
extension SCNRecorder: ARSCNViewDelegate {
    
    var arSceneViewDelegate: ARSCNViewDelegate? {
        get {
            return delegate as? ARSCNViewDelegate
        }
        set {
            delegate = newValue
        }
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        return arSceneViewDelegate?.renderer?(renderer, nodeFor: anchor) ?? SCNNode(geometry: nil)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        arSceneViewDelegate?.renderer?(renderer, didAdd: node, for: anchor)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        arSceneViewDelegate?.renderer?(renderer, willUpdate: node, for: anchor)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        arSceneViewDelegate?.renderer?(renderer, didUpdate: node, for: anchor)
    }
    
    @objc
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        arSceneViewDelegate?.renderer?(renderer, didRemove: node, for: anchor)
    }
    
    
    // MARK: ARSessionObserver
    @objc
    public func session(_ session: ARSession, didFailWithError error: Swift.Error) {
        arSceneViewDelegate?.session?(session, didFailWithError: error)
    }
    
    @objc
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        arSceneViewDelegate?.session?(session, cameraDidChangeTrackingState: camera)
    }
    
    @objc
    public func sessionWasInterrupted(_ session: ARSession) {
        arSceneViewDelegate?.sessionWasInterrupted?(session)
    }
    
    @objc
    public func sessionInterruptionEnded(_ session: ARSession) {
        arSceneViewDelegate?.sessionInterruptionEnded?(session)
    }
    
    @available(iOS 11.3, *)
    @objc
    public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return arSceneViewDelegate?.sessionShouldAttemptRelocalization?(session) ?? false
    }
    
    @objc
    public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
        arSceneViewDelegate?.session?(session, didOutputAudioSampleBuffer: audioSampleBuffer)
        recorder.produceAudioSampleBuffer(audioSampleBuffer)
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
