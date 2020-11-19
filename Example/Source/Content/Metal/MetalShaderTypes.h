//
//  MetalShaderTypes.h
//  Example
//
//  Created by VG on 18.11.2020.
//  Copyright © 2020 GORA Studio. All rights reserved.
//

#ifndef MetalShaderTypes_h
#define MetalShaderTypes_h

#include <simd/simd.h>

typedef enum MetalVertexInputIndex
{
  MetalVertexInputIndexVertices = 0,
  MetalVertexInputIndexUniforms = 1,
} MetalVertexInputIndex;

typedef struct
{
    vector_float2 position;
    vector_float3 color;
} MetalVertex;

typedef struct
{
    float scale;
    vector_uint2 viewportSize;
} MetalUniforms;


#endif /* MetalShaderTypes_h */
