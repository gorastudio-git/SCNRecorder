//
//  Controllable.swift
//  Example
//
//  Created by VG on 19.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation
import UIKit
import SCNRecorder

protocol Controllable {

  func takePhoto(handler: @escaping (UIImage) -> Void)

  func startVideoRecording(size: CGSize) throws -> VideoRecording

  func finishVideoRecording(handler: @escaping (URL) -> Void)
}

typealias ControllableViewController = UIViewController & Controllable
