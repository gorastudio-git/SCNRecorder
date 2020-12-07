//
//  VideoPreviewController.swift
//  Example
//
//  Created by Vladislav Grigoryev on 19.11.2020.
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
import AVKit

final class VideoPreviewController: AVPlayerViewController {

  let videoURL: URL

  init(videoURL: URL) {
    self.videoURL = videoURL
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    player = AVPlayer(url: videoURL)

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .action,
      target: self,
      action: #selector(share)
    )
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if isMovingFromParent {
      try? FileManager.default.removeItem(at: videoURL)
    }
  }

  @objc func share() {
    present(
      UIActivityViewController(activityItems: [videoURL], applicationActivities: nil),
      animated: true,
      completion: nil
    )
  }
}
