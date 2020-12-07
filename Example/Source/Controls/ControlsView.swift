//
//  ControlsView.swift
//  Example
//
//  Created by Vladislav Grigoryev on 18.11.2020.
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
