//
//  Button.swift
//  Example
//
//  Created by VG on 19.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit

class Button: UIButton {

  typealias Action = () -> Void

  @objc func _touchUpInside() { touchUpInside?() }
  var touchUpInside: Action? {
    didSet {
      switch (oldValue, touchUpInside) {
      case (.none, .some):
        addTarget(self, action: #selector(_touchUpInside), for: .touchUpInside)
      case (.some, .none):
        removeTarget(self, action: #selector(_touchUpInside), for: .touchUpInside)
      default: break
      }
    }
  }
}
