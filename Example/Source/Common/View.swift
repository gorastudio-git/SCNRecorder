//
//  View.swift
//  Example
//
//  Created by VG on 19.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit

class View: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @available(*, unavailable)
  override func awakeFromNib() {
    fatalError("awakeFromNib() has not been implemented")
  }

  private func setupView() {
    addSubviews()
    makeConstraints()
  }

  func addSubviews() { }

  func makeConstraints() { }
}
