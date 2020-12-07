//
//  MetalTexturePool.swift
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

final class MetalTexturePool {

  enum Error: Swift.Error {

    case metalTextureCacheAllocation(errorCode: CVReturn)

    case metalTextureAllocation(errorCode: CVReturn)

    case noMTLTexture
  }

  let device: MTLDevice

  let pixelBufferPool: PixelBufferPool

  let attributes: MetalTexture.Attributes

  let metalTextureCache: CVMetalTextureCache

  init(
    device: MTLDevice,
    pixelBufferPool: PixelBufferPool,
    attributes: MetalTexture.Attributes
  ) throws {
    self.device = device
    self.pixelBufferPool = pixelBufferPool
    self.attributes = attributes

    var metalTextureCache: CVMetalTextureCache?
    let errorCode = CVMetalTextureCacheCreate(
      nil,
      [kCVMetalTextureUsage: MTLTextureUsage.shaderWrite] as CFDictionary,
      device,
      nil,
      &metalTextureCache
    )

    switch (errorCode, metalTextureCache) {
    case (kCVReturnSuccess, .some(let metalTextureCache)):
      self.metalTextureCache = metalTextureCache
    default:
      throw Error.metalTextureCacheAllocation(errorCode: errorCode)
    }
  }

  func getMetalTexture(
    propagatedAttachments: [String: Any]? = nil,
    nonPropagatedAttachments: [String: Any]? = nil
  ) throws -> MetalTexture {
    let pixelBuffer = try pixelBufferPool.getPixelBuffer(
      propagatedAttachments: propagatedAttachments,
      nonPropagatedAttachments: nonPropagatedAttachments
    )

    var cvMetalTexture: CVMetalTexture?
    let errorCode = CVMetalTextureCacheCreateTextureFromImage(
      nil,
      metalTextureCache,
      pixelBuffer.cvPxelBuffer,
      nil,
      attributes.pixelFormat,
      attributes.width,
      attributes.height,
      attributes.planeIndex,
      &cvMetalTexture
    )

    switch (errorCode, cvMetalTexture) {
    case (kCVReturnSuccess, .some(let cvMetalTexture)):
      guard let mtlTexture = CVMetalTextureGetTexture(cvMetalTexture) else {
        throw Error.noMTLTexture
      }
      return MetalTexture(
        attributes: attributes,
        pixelBuffer: pixelBuffer,
        cvMetalTexture: cvMetalTexture,
        mtlTexture: mtlTexture
      )
    default:
      throw Error.metalTextureAllocation(errorCode: errorCode)
    }
  }
}
