//
//  TestRenderer.swift
//  SCNRecorderTests
//
//  Created by Vladislav Grigoryev on 04.12.2020.
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
import UIKit
import Metal

final class TestRenderer {

  enum Error: Swift.Error {

    case cantMakeCommandQueue

    case cantMakeVerticesBuffer

    case cantMakeVertexShaderFunction

    case cantMakeFragmentShaderFunction

    case cantTakeNextDrawable

    case cantMakeCommandBuffer

    case cantMakeRenderCommandEncoder
  }

  static func makeColor(pixelFormat: MTLPixelFormat) -> vector_float3 {
    let uiColor = pixelFormat.isWideGamut
      ? UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
      : UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

    let color = uiColor.vec3
    guard pixelFormat.isSRGB else { return color }

    func gammaEncoded(_ component: Float) -> Float {
      abs(component) <= 0.04045
        ? component / 12.92
        : sign(component) * powf((abs(component) + 0.055) / 1.055, 2.4)
    }

    return vector_float3(
      gammaEncoded(color.x),
      gammaEncoded(color.y),
      gammaEncoded(color.z)
    )
  }

  static func makeQuadVertices(color: vector_float3) -> [MetalVertex] {
    return [
      MetalVertex(position: vector_float2(250, -250), color: color),
      MetalVertex(position: vector_float2(-250, -250), color: color),
      MetalVertex(position: vector_float2(-250, 250), color: color),

      MetalVertex(position: vector_float2(250, -250), color: color),
      MetalVertex(position: vector_float2(-250, 250), color: color),
      MetalVertex(position: vector_float2(250, 250), color: color)
    ]
  }

  let device: MTLDevice

  let commandQueue: MTLCommandQueue

  let pipelineState: MTLRenderPipelineState

  let quadVertices: [MetalVertex]

  let vertices: MTLBuffer

  let drawableRenderDescriptor: MTLRenderPassDescriptor

  let viewportSize: vector_uint2

  let color: vector_float3

  init(
    viewportSize: CGSize,
    device: MTLDevice,
    pixelFormat: MTLPixelFormat
  ) throws {
    self.device = device
    self.viewportSize = vector_uint2(
      UInt32(viewportSize.width),
      UInt32(viewportSize.height)
    )

    guard let commandQueue = device.makeCommandQueue() else { throw Error.cantMakeCommandQueue }
    self.commandQueue = commandQueue

    drawableRenderDescriptor = MTLRenderPassDescriptor()

    drawableRenderDescriptor.colorAttachments[0].loadAction = .clear
    drawableRenderDescriptor.colorAttachments[0].storeAction = .store
    drawableRenderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 1, 1, 1)

    color = Self.makeColor(pixelFormat: pixelFormat)
    quadVertices = Self.makeQuadVertices(color: color)
    guard let vertices = device.makeBuffer(
      bytes: quadVertices,
      length: MemoryLayout<MetalVertex>.stride * quadVertices.count,
      options: .storageModeShared
    ) else {
      throw Error.cantMakeVerticesBuffer
    }

    self.vertices = vertices
    self.vertices.label = "Quad"

    let library = try device.makeDefaultLibrary(bundle: Bundle(for: TestRenderer.self))
    guard let vertexProgram = library.makeFunction(name: "vertexShader") else {
      throw Error.cantMakeVertexShaderFunction
    }

    guard let fragmentProgram = library.makeFunction(name: "fragmentShader") else {
      throw Error.cantMakeFragmentShaderFunction
    }

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.label = "QuadPipeline"
    pipelineDescriptor.vertexFunction = vertexProgram
    pipelineDescriptor.fragmentFunction = fragmentProgram
    pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat

    pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
  }

  func renderToMetalLayer(_ metalLayer: CAMetalLayer) throws {
    try autoreleasepool { try _renderToMetalLayer(metalLayer) }
  }

  private func _renderToMetalLayer(_ metalLayer: CAMetalLayer) throws {
    
    guard let currentDrawable = metalLayer.nextDrawable() else {
      throw Error.cantTakeNextDrawable
    }
    drawableRenderDescriptor.colorAttachments[0].texture = currentDrawable.texture

    guard let commandBuffer = commandQueue.makeCommandBuffer() else {
      throw Error.cantMakeCommandBuffer
    }

    guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
      descriptor: drawableRenderDescriptor
    ) else {
      throw Error.cantMakeRenderCommandEncoder
    }

    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(
      vertices,
      offset: 0,
      index: Int(MetalVertexInputIndexVertices.rawValue)
    )

    var uniforms = MetalUniforms(
      scale: 1.0,
      viewportSize: viewportSize
    )
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<MetalUniforms>.size,
      index: Int(MetalVertexInputIndexUniforms.rawValue)
    )

    renderEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: quadVertices.count
    )
    renderEncoder.endEncoding()

    commandBuffer.present(currentDrawable)
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
  }
}
