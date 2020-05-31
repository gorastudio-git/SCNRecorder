//
//  InternalRecorder.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

import Foundation

protocol InternalRecorder: Recorder {

  var error: Swift.Error? { get set }
}
