//
//  MetalTexture.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 28.11.2020.
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
import AVFoundation
import Metal

final class MetalTexture {

  struct Attributes: Hashable {

    var width: Int

    var height: Int

    var pixelFormat: MTLPixelFormat

    var planeIndex: Int = 0
  }

  let attributes: Attributes

  let pixelBuffer: PixelBuffer

  let cvMetalTexture: CVMetalTexture

  let mtlTexture: MTLTexture

  init(
    attributes: Attributes,
    pixelBuffer: PixelBuffer,
    cvMetalTexture: CVMetalTexture,
    mtlTexture: MTLTexture
  ) {
    self.attributes = attributes
    self.pixelBuffer = pixelBuffer
    self.cvMetalTexture = cvMetalTexture
    self.mtlTexture = mtlTexture
  }
}
