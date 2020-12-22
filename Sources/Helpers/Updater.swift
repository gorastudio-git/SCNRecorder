//
//  Updater.swift
//  Example
//
//  Created by VG on 18.12.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit

final class Updater {

  lazy var displayLink: CADisplayLink = {
    let displayLink = CADisplayLink(target: self, selector: #selector(update))
    displayLink.isPaused = true
    displayLink.add(to: .main, forMode: .common)
    return displayLink
  }()

  var preferredUpdatesPerSecond: Int {
    get { displayLink.preferredFramesPerSecond }
    set { displayLink.preferredFramesPerSecond = newValue }
  }

  var isPaused: Bool {
    get { displayLink.isPaused }
    set { displayLink.isPaused = newValue }
  }

  var onUpdate: (() -> Void)?

  func invalidate() { displayLink.invalidate() }

  @objc func update() { onUpdate?() }
}
