//
//  Shaders.metal
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

#include <metal_stdlib>
#include "Shaders.h"
#include "AffineTransform.h"
#include "imageScaling.h"
using namespace metal;

vertex RasterizerData vertexShader(const device packed_float3* vertexData [[ buffer(0) ]],
                                   unsigned int vid [[ vertex_id ]]) {
    RasterizerData out;
    out.pos = float4(vertexData[vid], 1);
    
    return out;
}

fragment half4 fragmentShader(RasterizerData in [[ stage_in ]],
                              const device packed_float2* viewHalfSize [[ buffer(0) ]],
                              const device packed_float2* imageCenters [[ buffer(1) ]],
                              const device packed_float2* imageHalfSizes [[ buffer(2) ]],
                              const device packed_float2* translations [[ buffer(3) ]],
                              const device float* scales [[ buffer(4) ]],
                              const device float* rotations [[ buffer(5) ]],
                              array<texture2d<float>, 2> textures [[ texture(0) ]],
                              sampler sampler2d [[ sampler(0) ]]) {
    bool insideAreaChekcArr[2] = { false, };
    float4 colorArr[2];
    
    for (int i = 0; i < 2; i++) {
        float2 scaledImageHalfSize = scaleImage(imageHalfSizes[i], *viewHalfSize);
        float3x3 transform = rotationMatrix(rotations[i]) * scaleMatrix(scales[i]) * translationMatrix(translations[i]) * translationMatrix(imageCenters[i]);
        float3 topLine = float3(0, 1, -scaledImageHalfSize.y) * transform;
        float3 bottomLine = float3(0, 1, scaledImageHalfSize.y) * transform;
        float3 leftLine = float3(1, 0, -scaledImageHalfSize.x) * transform;
        float3 rightLine = float3(1, 0, scaledImageHalfSize.x) * transform;
        float3 solution = float3(in.pos.x, in.pos.y, 1);
        bool isInsideArea = dot(topLine, solution) < 0 && dot(bottomLine, solution) > 0 && dot(leftLine, solution) < 0 && dot(rightLine, solution) > 0;
        
        if (isInsideArea) {
            float3 beforeNormalization = translationMatrix(-scaledImageHalfSize) * transform * solution;
            float2 normalized = float2(beforeNormalization.x, beforeNormalization.y) / (scaledImageHalfSize * 2);
            float4 color = textures[i].sample(sampler2d, normalized);
            
            insideAreaChekcArr[i] = true;
            colorArr[i] = color;
        }
    }
    
    // Mix color
    bool isFirstColor = true;
    float4 mixedColor = float4(1);
    
    for (int i = 0; i < 2; i++) {
        if (insideAreaChekcArr[i] && isFirstColor) {
            mixedColor = colorArr[i];
            isFirstColor = false;
        } else if (insideAreaChekcArr[i]) {
            mixedColor = mix(mixedColor, colorArr[i], 0.5);
        }
    }
        
    return half4(mixedColor.r, mixedColor.g, mixedColor.b, 1);
}
