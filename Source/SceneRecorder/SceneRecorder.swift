//
//  SceneRecorder.swift
//  SceneRecorder
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
import SceneKit
import ARKit

public extension SceneRecorder {
  enum Error: Swift.Error {

    case notRecordableView

    case recordableLayer

    case eaglContext

    case metalSimulator

    case pixelBuffer(errorCode: CVReturn)

    case pixelBufferFactory

    case unknownAPI
  }
}

public final class SceneRecorder: NSObject {

  weak var delegate: AnyObject?

  let mediaRecorder: MediaRecorder

  let videoInput: SceneVideoInput

  lazy var audioInput: SceneAudioInput = {
    let audioInput = SceneAudioInput(queue: queue)
    mediaRecorder.audioInput = audioInput
    return audioInput
  }()

  let queue = DispatchQueue(label: "SCNRecorder.Processing.DispatchQueue", qos: .userInitiated)

  public init(_ recordableView: RecordableView, timeScale: CMTimeScale = 600) throws {
    self.videoInput = try SceneVideoInput(recordableView: recordableView, timeScale: timeScale)
    self.mediaRecorder = MediaRecorder(queue: queue)
    self.mediaRecorder.videoInput = self.videoInput
  }
}

public extension SceneRecorder {

  var filters: [Filter] {
    get { mediaRecorder.filters }
    set { mediaRecorder.filters = newValue }
  }

  /// Can be used for debug
  var error: Property<Swift.Error?> { mediaRecorder.error }

  func makeVideoRecording(to url: URL, fileType: AVFileType = .mov) throws -> VideoRecording {
    try mediaRecorder.makeVideoRecording(to: url, fileType: fileType)
  }

  func takePhoto(
    scale: CGFloat = UIScreen.main.scale,
    orientation: UIImage.Orientation = .up,
    completionHandler handler: @escaping (UIImage) -> Void
  ) {
    mediaRecorder.takePhoto(scale: scale, orientation: orientation, completionHandler: handler)
  }

  func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) {
    mediaRecorder.takeCoreImage(completionHandler: handler)
  }

  func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
    mediaRecorder.takePixelBuffer(completionHandler: handler)
  }
}

// MARK: - SCNSceneRendererDelegate
extension SceneRecorder: SCNSceneRendererDelegate {

  var sceneViewDelegate: SCNSceneRendererDelegate? {
    get { delegate as? SCNSceneRendererDelegate }
    set { delegate = newValue }
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    updateAtTime time: TimeInterval
  ) {
    sceneViewDelegate?.renderer?(renderer, updateAtTime: time)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    didApplyAnimationsAtTime time: TimeInterval
  ) {
    sceneViewDelegate?.renderer?(renderer, didApplyAnimationsAtTime: time)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    didSimulatePhysicsAtTime time: TimeInterval
  ) {
    sceneViewDelegate?.renderer?(renderer, didSimulatePhysicsAtTime: time)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    didApplyConstraintsAtTime time: TimeInterval
  ) {
    sceneViewDelegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    willRenderScene scene: SCNScene,
    atTime time: TimeInterval
  ) {
    sceneViewDelegate?.renderer?(renderer, willRenderScene: scene, atTime: time)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    didRenderScene scene: SCNScene,
    atTime time: TimeInterval
  ) {
    sceneViewDelegate?.renderer?(renderer, didRenderScene: scene, atTime: time)

    do { try videoInput.renderer(renderer, didRenderScene: scene, atTime: time) }
    catch { self.error.value = error }
  }
}

// MARK: - ARSCNViewDelegate
extension SceneRecorder: ARSCNViewDelegate {

  var arSceneViewDelegate: ARSCNViewDelegate? {
    get { delegate as? ARSCNViewDelegate }
    set { delegate = newValue }
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    nodeFor anchor: ARAnchor
  ) -> SCNNode? {
    arSceneViewDelegate?.renderer?(renderer, nodeFor: anchor) ?? SCNNode(geometry: nil)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    didAdd node: SCNNode,
    for anchor: ARAnchor
  ) {
    arSceneViewDelegate?.renderer?(renderer, didAdd: node, for: anchor)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    willUpdate node: SCNNode,
    for anchor: ARAnchor
  ) {
    arSceneViewDelegate?.renderer?(renderer, willUpdate: node, for: anchor)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    didUpdate node: SCNNode,
    for anchor: ARAnchor
  ) {
    arSceneViewDelegate?.renderer?(renderer, didUpdate: node, for: anchor)
  }

  @objc
  public func renderer(
    _ renderer: SCNSceneRenderer,
    didRemove node: SCNNode,
    for anchor: ARAnchor
  ) {
    arSceneViewDelegate?.renderer?(renderer, didRemove: node, for: anchor)
  }

  // MARK: ARSessionObserver
  @objc
  public func session(
    _ session: ARSession,
    didFailWithError error: Swift.Error
  ) {
    arSceneViewDelegate?.session?(session, didFailWithError: error)
  }

  @objc
  public func session(
    _ session: ARSession,
    cameraDidChangeTrackingState camera: ARCamera
  ) {
    arSceneViewDelegate?.session?(session, cameraDidChangeTrackingState: camera)
  }

  @objc
  public func sessionWasInterrupted(
    _ session: ARSession
  ) {
    arSceneViewDelegate?.sessionWasInterrupted?(session)
  }

  @objc
  public func sessionInterruptionEnded(
    _ session: ARSession
  ) {
    arSceneViewDelegate?.sessionInterruptionEnded?(session)
  }

  @available(iOS 11.3, *)
  @objc
  public func sessionShouldAttemptRelocalization(
    _ session: ARSession
  ) -> Bool {
    arSceneViewDelegate?.sessionShouldAttemptRelocalization?(session) ?? false
  }

  @objc
  public func session(
    _ session: ARSession,
    didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer
  ) {
    arSceneViewDelegate?.session?(session, didOutputAudioSampleBuffer: audioSampleBuffer)
    audioInput.session(session, didOutputAudioSampleBuffer: audioSampleBuffer)
  }

  #if compiler(>=5.1)
  @available(iOS 13.0, *)
  @objc
  public func session(
    _ session: ARSession,
    didOutputCollaborationData data: ARSession.CollaborationData
  ) {
    arSceneViewDelegate?.session?(session, didOutputCollaborationData: data)
  }
  #endif
}
