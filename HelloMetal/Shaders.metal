//
//  Shaders.metal
//  HelloMetal
//
//  Created by Main Account on 10/2/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    packed_float3 position;
    packed_float4 color;
    packed_float2 textureCoordinate;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textureCoordinate;
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

// this vertex shader will reurn a VertexOut strcut defined above
//  it will also take input of VertexIn, also defined above, which matches the structure of Vertex
vertex VertexOut basic_vertex(const device VertexIn* vertex_array   [[ buffer(0) ]],
                              const device Uniforms& uniforms       [[ buffer(1) ]],
                              unsigned int vid                      [[ vertex_id ]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    // get the current vertex from the array
    VertexIn VertexIn = vertex_array[vid];
    
    // create a VertexOut and pass data from VertexIn to VertexOut
    VertexOut VertexOut;
    //VertexOut.position = mv_Matrix * float4(VertexIn.position, 1);
    VertexOut.position = proj_Matrix * mv_Matrix * float4(VertexIn.position, 1);
    VertexOut.color = VertexIn.color;
    
    VertexOut.textureCoordinate = VertexIn.textureCoordinate;
    
    return VertexOut;
    
}

// this fragment shader takes interpolated values from VertexOut structure
fragment float4 basic_fragment(VertexOut interpolated [[ stage_in ]],
                               texture2d<float> tex2D [[ texture(0) ]],
                               sampler sampler2D      [[ sampler(0) ]]) {
    //return color for the current fragment
    float4 color = tex2D.sample(sampler2D, interpolated.textureCoordinate);
    return color;
    
}
