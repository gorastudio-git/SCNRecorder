//
//  RKViewController.swift
//  Example
//
//  Created by VG on 17.08.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import RealityKit
import AVKit

import SCNRecorder

class RKViewController: UIViewController {

  @IBOutlet var sceneView: ARView!

  @IBOutlet var durationLabel: UILabel!

  @IBOutlet var photoButton: UIButton!

  @IBOutlet var videoButton: UIButton!

  var lastRecordingURL: URL?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Load the "Box" scene from the "Experience" Reality File
    do {
      let boxAnchor = try Experience.loadBox()

      // Add the box anchor to the scene
      sceneView.scene.anchors.append(boxAnchor)
    }
    catch { }

    // It is recommended to prepare the view for recording at viewDidLoad
    do { try sceneView.prepareForRecording() }
    catch { print("Something went wrong during recording preparation: \(error)") }
  }

  @IBAction func takePhoto(_ sender: UIButton) {
    do {
      // A fastest way to capture photo
      try sceneView.takePhoto { (photo) in
        // Create and present photo preview controller
        let controller = PhotoPreviewController(photo: photo)
        self.navigationController?.pushViewController(controller, animated: true)

        // Enable buttons
        self.photoButton.isEnabled = true
        self.videoButton.isEnabled = true
      }

      // Disable buttons for a while
      photoButton.isEnabled = false
      videoButton.isEnabled = false
    }
    catch { print("Something went wrong during photo-capture preparation: \(error)") }
  }

  @IBAction func startVideoRecording() {
    do {
      var settings = VideoSettings()
      settings.size = CGSize(width: 720, height: 1280)
      let videoRecording = try sceneView.startVideoRecording(settings: settings)

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
      // Create a controller to preview captured video
      let controller = AVPlayerViewController()

      // Use an url from the recording
      // The url is the same you passed to makeVideoRecording
      controller.player = AVPlayer(url: recording.url)

      // I don't recommend you to do this in an real app
      self.lastRecordingURL = recording.url
      controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .action,
        target: self,
        action: #selector(ARSCNViewController.share(_:))
      )

      // Present the controller
      self.navigationController?.pushViewController(controller, animated: true)

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

  @objc func share(_ sender: Any) {
    guard let url = lastRecordingURL else { return }

    present(
      UIActivityViewController(activityItems: [url], applicationActivities: nil),
      animated: true,
      completion: nil
    )
  }
}
