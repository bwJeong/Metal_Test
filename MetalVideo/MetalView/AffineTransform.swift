//
//  AffineTransform.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

import simd

func translationMatrix(_ translation: SIMD2<Float>) -> float3x3 {
  let tx = translation.x;
  let ty = translation.y;
  let transformMatrix = float3x3(SIMD3<Float>(  1,   0, 0),
                                 SIMD3<Float>(  0,   1, 0),
                                 SIMD3<Float>(-tx, -ty, 1));
  
  return transformMatrix;
}

func scaleMatrix(_ scale: Float) -> float3x3 {
  let s = 1 / scale;
  let transformMatrix = float3x3(SIMD3<Float>(s, 0, 0),
                                 SIMD3<Float>(0, s, 0),
                                 SIMD3<Float>(0, 0, 1));
  
  return transformMatrix;
}

func rotationMatrix(_ radian: Float) -> float3x3 {
  let rad = radian;
  let transformMatrix = float3x3(SIMD3<Float>(cos(rad), -sin(rad), 0),
                                 SIMD3<Float>(sin(rad),  cos(rad), 0),
                                 SIMD3<Float>(       0,         0, 1));
  
  return transformMatrix;
}
