//
//  EtcMethods.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/04.
//

import UIKit
import simd

func isInsideArea(viewHalfSize: SIMD2<Float>,
                  imageHalfSize: SIMD2<Float>,
                  imageCenter: SIMD2<Float>,
                  translation: SIMD2<Float>,
                  scale: Float,
                  rotation: Float,
                  location: CGPoint) -> Bool {
    let scaledImageHalfSize = scaleImage(imageHalfSize: imageHalfSize, viewHalfSize: viewHalfSize);
    let transform: float3x3 = rotationMatrix(rotation) * scaleMatrix(scale) * translationMatrix(translation) * translationMatrix(imageCenter)
    let topLine = SIMD3<Float>(0, 1, -scaledImageHalfSize.y) * transform;
    let bottomLine = SIMD3<Float>(0, 1, scaledImageHalfSize.y) * transform;
    let leftLine = SIMD3<Float>(1, 0, -scaledImageHalfSize.x) * transform;
    let rightLine = SIMD3<Float>(1, 0, scaledImageHalfSize.x) * transform;
    let solution = SIMD3<Float>(Float(location.x), Float(location.y), 1);
    let isInside = dot(topLine, solution) < 0 && dot(bottomLine, solution) > 0 && dot(leftLine, solution) < 0 && dot(rightLine, solution) > 0
    
    if isInside {
        return true
    }
    
    return false
}

func scaleImage(imageHalfSize: SIMD2<Float>, viewHalfSize: SIMD2<Float>) -> SIMD2<Float> {
    if (max(imageHalfSize.x, imageHalfSize.y) < viewHalfSize.x) {
        return imageHalfSize
    }
    
    let scaledImageHalfSize = imageHalfSize * (viewHalfSize.x / 2) / max(imageHalfSize.x, imageHalfSize.y)
    
    return scaledImageHalfSize
}
