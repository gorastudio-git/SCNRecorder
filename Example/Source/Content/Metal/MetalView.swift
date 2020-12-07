//
//  MetalView.swift
//  Example
//
//  Created by VG on 18.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit
import SCNRecorder

@available(iOS 13.0, *)
protocol MetalViewDelegate: AnyObject {

  var commandQueue: MTLCommandQueue? { get }

  func drawableResize(_ size: CGSize)

  func renderToMetalLayer(_ metalLayer: CAMetalLayer)
}

@available(iOS 13.0, *)
final class MetalView: UIView {

  override class var layerClass: AnyClass { CAMetalLayer.self }

  // swiftlint:disable force_cast
  lazy var metalLayer = layer as! CAMetalLayer
  // swiftlint:enable force_cast

  weak var delegate: MetalViewDelegate?

  private var displayLink: CADisplayLink?

  var isPaused = false {
    didSet { displayLink?.isPaused = isPaused }
  }

  override var contentScaleFactor: CGFloat {
    didSet { resizeDrawable() }
  }

  override var frame: CGRect {
    didSet { resizeDrawable() }
  }

  override var bounds: CGRect {
    didSet { resizeDrawable() }
  }

  deinit { stopRenderLoop() }

  func setupView() {
    subscribeToNotifications()
  }

  override func didMoveToWindow() {
    stopRenderLoop()

    guard let window = window else { return }
    startRenderLoop(window.screen)
    resizeDrawable(scaleFactor: window.screen.nativeScale)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    resizeDrawable()
  }
}

@available(iOS 13.0, *)
extension MetalView {

  func startRenderLoop(_ screen: UIScreen) {
    displayLink = screen.displayLink(withTarget: self, selector: #selector(render))
    displayLink?.isPaused = isPaused
    displayLink?.preferredFramesPerSecond = 60
    displayLink?.add(to: .current, forMode: .common)
  }

  func stopRenderLoop() {
    displayLink?.invalidate()
    displayLink = nil
  }

  @objc func render() {
    guard let delegate = delegate else { return }
    delegate.renderToMetalLayer(metalLayer)

    if let commandQueue = delegate.commandQueue {
      recorder?.render(using: commandQueue)
    }
    else {
      recorder?.render()
    }
  }

  func resizeDrawable() {
    guard let window = window else { return }
    resizeDrawable(scaleFactor: window.screen.nativeScale)
  }

  func resizeDrawable(scaleFactor: CGFloat) {
    var newSize = bounds.size
    newSize.width *= scaleFactor
    newSize.height *= scaleFactor

    guard newSize != metalLayer.drawableSize else { return }
    guard newSize.width > 0, newSize.height > 0 else { return }

    metalLayer.drawableSize = newSize
    delegate?.drawableResize(newSize)
  }
}

// MARK: - Notifications
@available(iOS 13.0, *)
extension MetalView {

  func subscribeToNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didEnterBackground(_:)),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willEnterForeground(_:)),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }

  @objc func didEnterBackground(_ notification: Notification) { isPaused = true }

  @objc func willEnterForeground(_ notification: Notification) { isPaused = false }
}

@available(iOS 13.0, *)
extension MetalView: MetalRecordable, SelfSceneRecordable {

  var recordableLayer: RecordableLayer? { metalLayer }
}
