//
//  RealityViewController.swift
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

class RealityViewController: UIViewController {

  @IBOutlet var sceneView: ARView!

  @IBOutlet var durationLabel: UILabel!

  @IBOutlet var photoButton: UIButton!

  @IBOutlet var videoButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Load the "Box" scene from the "Experience" Reality File
    do {
      let boxAnchor = try Experience.loadBox()

      // Add the box anchor to the scene
      sceneView.scene.anchors.append(boxAnchor)
//      sceneView.automaticallyConfigureSession = false
    }
    catch { }

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

  @IBAction func takePhoto(_ sender: UIButton) {
    // A fastest way to capture photo
    sceneView.takePhoto { (photo) in
      // Create and present photo preview controller


      // Enable buttons
      self.photoButton.isEnabled = true
      self.videoButton.isEnabled = true
    }

    // Disable buttons for a while
    photoButton.isEnabled = false
    videoButton.isEnabled = false
  }

  @IBAction func startVideoRecording() {
    do {
      let videoRecording = try sceneView.startVideoRecording(
        size: CGSize(width: 720, height: 1280)
      )

      // Observe for duration
      videoRecording.$duration.observe { [weak self] duration in
        DispatchQueue.main.async {
          let seconds = Int(duration)
          self?.durationLabel.text = String(format: "%02d:%02d", seconds / 60, seconds % 60)
        }
      }

      // Update UI
      photoButton.isEnabled = false
      videoButton.setTitle("Finish Video", for: .normal)
      videoButton.removeTarget(self, action: #selector(startVideoRecording), for: .touchUpInside)
      videoButton.addTarget(self, action: #selector(finishVideoRecording), for: .touchUpInside)
    }
    catch { print("Something went wrong during video-recording preparation: \(error)") }
  }

  @objc func finishVideoRecording() {
    // Finish recording
    sceneView.finishVideoRecording { (recording) in

      // Update UI
      self.durationLabel.text = nil
      self.photoButton.isEnabled = true
      self.videoButton.isEnabled = true
    }

    // Update UI
    videoButton.isEnabled = false
    videoButton.setTitle("Start Video", for: .normal)
    videoButton.removeTarget(self, action: #selector(finishVideoRecording), for: .touchUpInside)
    videoButton.addTarget(self, action: #selector(startVideoRecording), for: .touchUpInside)
  }


}
