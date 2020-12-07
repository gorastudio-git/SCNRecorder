//
//  UIColor+Helpers.swift
//  Example
//
//  Created by VG on 01.12.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

  var vec3: vector_float3 {
    var colors: (red: CGFloat, green: CGFloat, blue: CGFloat) = (0, 0, 0)
    getRed(&colors.red, green: &colors.green, blue: &colors.blue, alpha: nil)
    return vector_float3(Float(colors.red), Float(colors.green), Float(colors.blue))
  }
}
