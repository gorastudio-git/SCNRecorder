//
//  MetalViewController.swift
//  Example
//
//  Created by VG on 18.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit
import SCNRecorder
import AVKit

final class MetalViewController: UIViewController {

  lazy var captureSession = metalView.recorder.flatMap {
    try? AVCaptureSession.makeAudioForRecorder($0)
  }

  // swiftlint:disable force_cast
  lazy var metalView = view as! MetalView
  // swiftlint:enable force_cast

  var renderer: SquadRenderer?

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

extension MetalViewController: MetalViewDelegate {

  func drawableResize(_ size: CGSize) {
    renderer?.drawableResize(size)
  }

  func renderToMetalLayer(_ metalLayer: CAMetalLayer) {
    renderer?.renderToMetalLayer(metalLayer)
  }
}

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
