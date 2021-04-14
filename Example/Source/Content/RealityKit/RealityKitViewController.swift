//
//  RealityKitViewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 17.08.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
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
import ARKit
import RealityKit
import AVKit

import SCNRecorder

@available(iOS 13.0, *)
class RealityKitViewController: UIViewController {

  // swiftlint:disable force_cast
  lazy var realityView: ARView = view as! ARView
  // swiftlint:enable force_cast

  override func loadView() { view = ARView() }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Load the "Box" scene from the "Experience" Reality File
    do {
      // For now cocoapods doesn't suppor rcproject files.
      #if !COCOAPODS
      let boxAnchor = try Experience.loadBox()

      // Add the box anchor to the scene
      realityView.scene.anchors.append(boxAnchor)
      #endif

      #if !targetEnvironment(simulator)
      realityView.automaticallyConfigureSession = false
      #endif
    }
    catch { }

    // You must call prepareForRecording() before capturing something using SCNRecorder
    // It is recommended to do that at viewDidLoad
    realityView.prepareForRecording()
  }

  #if !targetEnvironment(simulator)
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // We want to record audio as well
    configuration.providesAudioData = true

    // Run the view's session
    realityView.session.run(configuration)
  }
  #endif
}

@available(iOS 13.0, *)
extension RealityKitViewController: Controllable {

  func takePhoto(handler: @escaping (UIImage) -> Void) {
    realityView.takePhoto(completionHandler: handler)
  }

  func startVideoRecording(size: CGSize) throws -> VideoRecording {
    try realityView.startVideoRecording(size: size)
  }

  func finishVideoRecording(handler: @escaping (URL) -> Void) {
    realityView.finishVideoRecording(completionHandler: { handler($0.url) })
  }
}
