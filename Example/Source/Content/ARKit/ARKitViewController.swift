//
//  ARKitViewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 12/03/2019.
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

import UIKit
import ARKit
import SCNRecorder

final class ARKitViewController: ViewController {

  // swiftlint:disable force_cast
  lazy var sceneView: ARSCNView = view as! ARSCNView
  // swiftlint:enable force_cast

  override func loadView() { view = ARSCNView() }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!

    // Set the scene to the view
    sceneView.scene = scene

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true

    // You must call prepareForRecording() before capturing something using SCNRecorder
    // It is recommended to do that at viewDidLoad
    sceneView.prepareForRecording()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // We want to record audio as well
    configuration.providesAudioData = true

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }
}

extension ARKitViewController: Controllable {

  func takePhoto(handler: @escaping (UIImage) -> Void) {
    sceneView.takePhoto(completionHandler: handler)
  }

  func startVideoRecording(size: CGSize) throws -> VideoRecording {
    try sceneView.startVideoRecording(size: size)
  }

  func finishVideoRecording(handler: @escaping (URL) -> Void) {
    sceneView.finishVideoRecording(completionHandler: { handler($0.url) })
  }
}
