//
//  SelfCleanRecordable.swift
//  SCNRecorder
//
//  Created by VG on 14.09.2020.
//

import Foundation
import ARKit

private var cleanKey: UInt8 = 0

public protocol SelfCleanRecordable: SelfRecordable, CleanRecordable { }

extension SelfCleanRecordable {

  var cleanStorage: AssociatedStorage<Clean<Self>> {
    AssociatedStorage(object: self, key: &cleanKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }

  var _clean: Clean<Self> {
    get {
      cleanStorage.get() ?? {
        let clean = Clean(cleanRecordable: self)
        _clean = clean
        return clean
      }()
    }
    set { cleanStorage.set(newValue) }
  }

  public var clean: SelfRecordable { _clean }
}

final class Clean<T: CleanRecordable>: SelfRecordable {

  public var recorder: (BaseRecorder & Renderable)? { cleanRecorder }

  var cleanRecorder: CleanRecorder<T>?

  var videoRecording: VideoRecording?

  weak var cleanRecordable: T?

  init(cleanRecordable: T) {
    self.cleanRecordable = cleanRecordable
  }

  func injectRecorder() {
    assert(cleanRecorder == nil)
    assert(cleanRecordable != nil)

    cleanRecorder = cleanRecordable.map { CleanRecorder($0) }
  }

  func prepareForRecording() {
    (cleanRecordable as? SCNView)?.swizzle()
    guard cleanRecorder == nil else { return }

    injectRecorder()
    assert(cleanRecorder != nil)
    (cleanRecordable as? SCNView)?.addDelegate(cleanRecorder!)
  }
}
