//
//  MetalShaders.metal
//  Example
//
//  Created by VG on 18.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Include header shared between this Metal shader code and C code executing Metal API commands
#include "MetalShaderTypes.h"

// Vertex shader outputs and per-fragment inputs
struct RasterizerData
{
    float4 clipSpacePosition [[position]];
    float3 color;
};

vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
             constant MetalVertex *vertexArray [[ buffer(MetalVertexInputIndexVertices) ]],
             constant MetalUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]])

{
    RasterizerData out;

    float2 pixelSpacePosition = vertexArray[vertexID].position.xy;

    // Scale the vertex by scale factor of the current frame
    pixelSpacePosition *= uniforms.scale;

    float2 viewportSize = float2(uniforms.viewportSize);

    // Divide the pixel coordinates by half the size of the viewport to convert from positions in
    // pixel space to positions in clip space
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.clipSpacePosition.z = 0.0;
    out.clipSpacePosition.w = 1.0;

    out.color = vertexArray[vertexID].color;

    return out;
}

fragment float4
fragmentShader(RasterizerData in [[stage_in]])
{
    return float4(in.color, 1.0);
}

