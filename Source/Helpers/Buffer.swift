//
//  Buffer.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 24.05.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

import Foundation

final class Buffer {

  static func zeroed(size: Int, alignment: Int = 1) -> Buffer {
    let buffer = Buffer(size: size, alignment: alignment)
    buffer.ptr.initializeMemory(as: UInt8.self, repeating: 0, count: size)
    return buffer
  }

  let size: Int

  let alignment: Int

  let ptr: UnsafeMutableRawPointer

  init(size: Int, alignment: Int) {
    self.size = size
    self.alignment = alignment
    self.ptr = .allocate(byteCount: size, alignment: alignment)
  }

  deinit { ptr.deallocate() }
}
