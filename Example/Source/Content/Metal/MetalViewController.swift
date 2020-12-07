//
//  MetalViewController.swift
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
import SCNRecorder
import AVKit

@available(iOS 13.0, *)
final class MetalViewController: UIViewController {

  lazy var captureSession = metalView.recorder.flatMap {
    try? AVCaptureSession.makeAudioForRecorder($0)
  }

  // swiftlint:disable force_cast
  lazy var metalView = view as! MetalView
  // swiftlint:enable force_cast

  var renderer: SquadRenderer?

  var commandQueue: MTLCommandQueue? { renderer?.commandQueue }

  override func loadView() {
    view = MetalView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    metalView.prepareForRecording()
    metalView.delegate = self

    guard let device = MTLCreateSystemDefaultDevice() else { return }
    metalView.metalLayer.device = device
    metalView.metalLayer.pixelFormat = .bgr10_xr_srgb

    renderer = SquadRenderer(device: device, pixelFormat: metalView.metalLayer.pixelFormat)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    captureSession?.startRunning()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    captureSession?.stopRunning()
  }
}

@available(iOS 13.0, *)
extension MetalViewController: MetalViewDelegate {

  func drawableResize(_ size: CGSize) {
    renderer?.drawableResize(size)
  }

  func renderToMetalLayer(_ metalLayer: CAMetalLayer) {
    renderer?.renderToMetalLayer(metalLayer)
  }
}

@available(iOS 13.0, *)
extension MetalViewController: Controllable {

  func takePhoto(handler: @escaping (UIImage) -> Void) {
    metalView.takePhoto(completionHandler: handler)
  }

  func startVideoRecording(size: CGSize) throws -> VideoRecording {
    try metalView.startVideoRecording(size: size)
  }

  func finishVideoRecording(handler: @escaping (URL) -> Void) {
    metalView.finishVideoRecording(completionHandler: { handler($0.url) })
  }
}
