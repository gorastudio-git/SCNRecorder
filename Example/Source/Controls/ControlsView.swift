//
//  ControlsView.swift
//  Example
//
//  Created by VG on 18.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit

import SnapKit

final class ControlsView: View {

  var childView: UIView? {
    didSet {
      oldValue?.removeFromSuperview()

      guard let childView = childView else { return }
      insertSubview(childView, at: 0)
      childView.snp.makeConstraints { $0.edges.equalTo(self) }
    }
  }

  lazy var takePhotoButton: Button = {
    let button = Button(type: .system)
    button.setTitle("Take Photo", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    return button
  }()

  lazy var startVideoRecordingButton: Button = {
    let button = Button(type: .system)
    button.setTitle("Start Video", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    return button
  }()

  lazy var finishVideoRecordingButton: Button = {
    let button = Button(type: .system)
    button.setTitle("Finish Video", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.isHidden = true
    return button
  }()

  lazy var buttonsStackView: UIStackView = {
    let stackView = UIStackView(
      arrangedSubviews: [
        takePhotoButton,
        startVideoRecordingButton,
        finishVideoRecordingButton
      ]
    )
    stackView.axis = .vertical
    return stackView
  }()

  override func addSubviews() {
    super.addSubviews()
    addSubview(buttonsStackView)
  }

  override func makeConstraints() {
    super.makeConstraints()
    buttonsStackView.snp.makeConstraints {
      $0.bottom.equalTo(safeAreaLayoutGuide).inset(32.0)
      $0.centerX.equalTo(safeAreaLayoutGuide)
    }
  }
}

// MARK: - Actions
extension ControlsView {

  var takePhoto: (() -> Void)? {
    get { takePhotoButton.touchUpInside }
    set { takePhotoButton.touchUpInside = newValue }
  }

  var startVideoRecording: (() -> Void)? {
    get { startVideoRecordingButton.touchUpInside }
    set { startVideoRecordingButton.touchUpInside = newValue }
  }

  var finishVideoRecording: (() -> Void)? {
    get { finishVideoRecordingButton.touchUpInside }
    set { finishVideoRecordingButton.touchUpInside = newValue }
  }
}
