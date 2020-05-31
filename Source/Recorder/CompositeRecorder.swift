//
//  CompositeRecorder.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 31.05.2020.
//

import Foundation
import AVFoundation

protocol CompositeRecorder: InternalRecorder {

  var composedRecorder: InternalRecorder { get }
}

extension CompositeRecorder {

  public var filters: [Filter] {
    get { composedRecorder.filters }
    set { composedRecorder.filters = newValue }
  }

  public var error: Swift.Error? {
    get { composedRecorder.error }
    set { composedRecorder.error = newValue }
  }
  
  public var errorObserver: Observable<Error?> { composedRecorder.errorObserver }

  public func makeVideoRecording(to url: URL, fileType: AVFileType) throws -> VideoRecording {
    try composedRecorder.makeVideoRecording(to: url, fileType: fileType)
  }

  public func takePhoto(
    scale: CGFloat,
    orientation: UIImage.Orientation,
    completionHandler handler: @escaping (UIImage) -> Void
  ) {
    composedRecorder.takePhoto(
      scale: scale,
      orientation: orientation,
      completionHandler: handler
    )
  }

  public func takeCoreImage(completionHandler handler: @escaping (CIImage) -> Void) {
    composedRecorder.takeCoreImage(completionHandler: handler)
  }

  public func takePixelBuffer(completionHandler handler: @escaping (CVPixelBuffer) -> Void) {
    composedRecorder.takePixelBuffer(completionHandler: handler)
  }
}
