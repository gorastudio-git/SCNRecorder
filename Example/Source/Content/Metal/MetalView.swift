//
//  MetalView.swift
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
