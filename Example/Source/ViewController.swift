//
//  ViewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 12/03/2019.
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


import UIKit
import SceneKit
import ARKit
import SCNRecorder
import AVKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var durationLabel: UILabel!
    
    @IBOutlet var photoButton: UIButton!
    
    @IBOutlet var videoButton: UIButton!
    
    var recorder: ARSCNRecorder!
    
    var videoRecording: VideoRecording? {
        didSet {
            videoRecording?.onDurationChanged = { [weak self] (duration) in
                DispatchQueue.main.async {
                    let seconds = Int(duration)
                    self?.durationLabel.text = String(format: "%02d:%02d", seconds / 60, seconds % 60)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recorder = try! ARSCNRecorder(sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Make our navigation bar transparent
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        // A fastest way to capture photo
        recorder?.takePhoto(completionHandler: { (photo) in
            DispatchQueue.main.async {
                
                // Create and present photo preview controller
                let controller = PhotoPreviewController(photo: photo)
                self.navigationController?.pushViewController(controller, animated: true)
                
                // Enable buttons
                self.photoButton.isEnabled = true
                self.videoButton.isEnabled = true
            }
        })
        
        // Disable buttons for a while
        photoButton.isEnabled = false
        videoButton.isEnabled = false
    }
    
    @IBAction func startVideoRecording() {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video.mov", isDirectory: false)
        try? fileManager.removeItem(at: url)
        
        // Store a strong reference to a viddeo recording
        videoRecording = try! recorder.makeVideoRecording(to: url)
        
        // Don't forget to resume recording
        videoRecording?.resume()
        
        // Update UI
        photoButton.isEnabled = false
        videoButton.setTitle("Finish Video", for: .normal)
        videoButton.removeTarget(self, action: #selector(startVideoRecording), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(finishVideoRecording), for: .touchUpInside)
    }
    
    @objc func finishVideoRecording() {
        // Finish recording
        videoRecording?.finish(completionHandler: { (recording) in
            DispatchQueue.main.async {
                // Create a controller to preview captured video
                let controller = AVPlayerViewController()
                
                // Use an url from the recording
                // The url is the same you passed to makeVideoRecording
                controller.player = AVPlayer(url: recording.url)
                
                // Present the controller
                self.navigationController?.pushViewController(controller, animated: true)
                
                // Update UI
                self.durationLabel.text = nil
                self.photoButton.isEnabled = true
                self.videoButton.isEnabled = true
            }
        })
        
        // It's safe to immediatly remove reference
        videoRecording = nil
        
        // Update UI
        videoButton.isEnabled = false
        videoButton.setTitle("Start Video", for: .normal)
        videoButton.removeTarget(self, action: #selector(finishVideoRecording), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(startVideoRecording), for: .touchUpInside)
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // Do you need to perform any actions when renderer get finished?
    }
}
