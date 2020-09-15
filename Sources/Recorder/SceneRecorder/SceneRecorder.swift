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

public final class SceneRecorder: BaseRecorder, Renderable, SCNSceneRendererDelegate {

  let videoInput: VideoInput

  init(videoInput: VideoInput) {
    self.videoInput = videoInput
    super.init()
    self.mediaSession.setVideoInput(videoInput)
  }

  #if !targetEnvironment(simulator)
  public convenience init<T: MetalRecordable>(_ recordable: T, timeScale: CMTimeScale = 600) throws {
    try self.init(videoInput: VideoInput(recordable: recordable, timeScale: timeScale))
  }
  #endif // !targetEnvironment(simulator)

  public convenience init<T: EAGLRecordable>(_ recordable: T, timeScale: CMTimeScale = 600) throws {
    try self.init(videoInput: VideoInput(recordable: recordable, timeScale: timeScale))
  }

  public convenience init<T: APIRecordable>(_ recordable: T, timeScale: CMTimeScale = 600) throws {
    try self.init(videoInput: VideoInput(recordable: recordable, timeScale: timeScale))
  }

  public func render(atTime time: TimeInterval) {
    do { try videoInput.render(atTime: time) }
    catch { self.error = error }
  }

  public func renderer(
    _ renderer: SCNSceneRenderer,
    didRenderScene scene: SCNScene,
    atTime time: TimeInterval
  ) { render(atTime: time) }
}
