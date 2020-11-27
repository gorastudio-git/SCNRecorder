//
//  ControlsViewController.swift
//  Example
//
//  Created by VG on 18.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit
import SCNRecorder

protocol ControlsViewControllerDelegate: AnyObject {

  func controlsViewControllerDidTakePhoto(_ photo: UIImage)

  func controlsViewControllerDidTakeVideoAt(_ url: URL)
}

final class ControlsViewController: ViewController {

  // swiftlint:disable force_cast
  lazy var controlsView = view as! ControlsView
  // swiftlint:enable force_cast

  let viewController: ControllableViewController

  weak var delegate: ControlsViewControllerDelegate?

  lazy var durationBarButtonItem = UIBarButtonItem(
    title: nil,
    style: .plain,
    target: nil,
    action: nil
  )

  init(_ viewController: ControllableViewController) {
    self.viewController = viewController
    super.init()
  }

  override func loadView() { view = ControlsView() }

  override func viewDidLoad() {
    super.viewDidLoad()
    bindView()

    navigationItem.rightBarButtonItem = durationBarButtonItem

    addChild(viewController)
    controlsView.childView = viewController.view
    viewController.didMove(toParent: self)
  }

  func bindView() {
    controlsView.takePhoto = weakify(Self.takePhoto)
    controlsView.startVideoRecording = weakify(Self.startVideoRecording)
    controlsView.finishVideoRecording = weakify(Self.finishVideoRecording)
  }

  func takePhoto() {
    controlsView.takePhotoButton.isEnabled = false
    controlsView.startVideoRecordingButton.isEnabled = false

    viewController.takePhoto { [weak self] (image) in
      guard let this = self else { return }

      DispatchQueue.main.async {
        this.delegate?.controlsViewControllerDidTakePhoto(image)

        this.controlsView.takePhotoButton.isEnabled = true
        this.controlsView.startVideoRecordingButton.isEnabled = true
      }
    }
  }

  func startVideoRecording() {
    do {
      let size = CGSize(width: 720, height: 1280)
      let videoRecording = try viewController.startVideoRecording(size: size)

      let formatted: (TimeInterval) -> String = {
        let seconds = Int($0)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
      }

      videoRecording.$duration.observe(on: .main) { [weak self] in
        guard let this = self else { return }
        this.durationBarButtonItem.title = formatted($0)
      }

      durationBarButtonItem.title = formatted(videoRecording.duration)
      controlsView.takePhotoButton.isEnabled = false
      controlsView.startVideoRecordingButton.isHidden = true
      controlsView.finishVideoRecordingButton.isHidden = false
    }
    catch {
      print("Something went wrong during video-recording preparation: \(error)")
    }
  }

  func finishVideoRecording() {
    viewController.finishVideoRecording { [weak self] url in
      guard let this = self else { return }

      DispatchQueue.main.async {
        this.delegate?.controlsViewControllerDidTakeVideoAt(url)

        this.durationBarButtonItem.title = nil
        this.controlsView.takePhotoButton.isEnabled = true
        this.controlsView.startVideoRecordingButton.isHidden = false
        this.controlsView.finishVideoRecordingButton.isHidden = true
      }
    }
  }
}
