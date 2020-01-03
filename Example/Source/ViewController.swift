//
//  ViewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 01/07/2019.
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
import SceneKit
import ARKit
import AVKit

import SCNRecorder

class ViewController: UIViewController {
  
  @IBOutlet var sceneView: SCNView!
  
  @IBOutlet var durationLabel: UILabel!
  
  @IBOutlet var photoButton: UIButton!
  
  @IBOutlet var videoButton: UIButton!
  
  var lastRecordingURL: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    // Create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    // Set the scene to the view
    sceneView.scene = scene
    sceneView.rendersContinuously = true
    
    do {
      try sceneView.prepareForRecording()
    }
    catch {
      print("Something went wrong during recording preparation: \(error)")
    }
  }
  
  @IBAction func takePhoto(_ sender: UIButton) {
    do {
      // A fastest way to capture photo
      try sceneView.takePhoto { (photo) in
        DispatchQueue.main.async {
          
          // Create and present photo preview controller
          let controller = PhotoPreviewController(photo: photo)
          self.navigationController?.pushViewController(controller, animated: true)
          
          // Enable buttons
          self.photoButton.isEnabled = true
          self.videoButton.isEnabled = true
        }
      }
      
      // Disable buttons for a while
      photoButton.isEnabled = false
      videoButton.isEnabled = false
    }
    catch {
      print("Something went wrong during photo-capture preparation: \(error)")
    }
  }
  
  @IBAction func startVideoRecording() {
    let fileManager = FileManager.default
    let url = fileManager.urls(
      for: .documentDirectory,
      in: .userDomainMask
    )[0].appendingPathComponent("video.mov", isDirectory: false)
    try? fileManager.removeItem(at: url)
    
    
    do {
      try sceneView.startVideoRecording(to: url)
      
      // Observe for duration
      sceneView.videoRecording?.duration.observer = { [weak self] duration in
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
    catch {
      print("Something went wrong during video-recording preparation: \(error)")
    }
  }
  
  @objc func finishVideoRecording() {
    // Finish recording
    sceneView.finishVideoRecording { (recording) in
      DispatchQueue.main.async {
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
