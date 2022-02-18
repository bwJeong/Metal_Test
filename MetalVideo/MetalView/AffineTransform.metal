//
//  AffineTransform.metal
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

#include <metal_stdlib>
#include "AffineTransform.h"
using namespace metal;

float3x3 translationMatrix(float2 translation) {
  float tx = translation.x;
  float ty = translation.y;
  float3x3 transformMatrix = float3x3(float3(  1,   0, 0),
                                      float3(  0,   1, 0),
                                      float3(-tx, -ty, 1));
  
  return transformMatrix;
}

float3x3 scaleMatrix(float scale) {
  float s = 1 / scale;
  float3x3 transformMatrix = float3x3(float3(s, 0, 0),
                                      float3(0, s, 0),
                                      float3(0, 0, 1));
  
  return transformMatrix;
}

float3x3 rotationMatrix(float radian) {
  float rad = radian;
  float3x3 transformMatrix = float3x3(float3(cos(rad), -sin(rad), 0),
                                      float3(sin(rad),  cos(rad), 0),
                                      float3(       0,         0, 1));
  
  return transformMatrix;
}
