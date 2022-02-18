//
//  imageScaling.metal
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

#include <metal_stdlib>
#include "imageScaling.h"
using namespace metal;

float2 scaleImage(float2 imageHalfSize, float2 viewHalfSize) {
    if (max(imageHalfSize.x, imageHalfSize.y) < viewHalfSize.x) {
        return imageHalfSize;
    }
    
    float2 scaledImageHalfSize = imageHalfSize * (viewHalfSize.x / 2) / max(imageHalfSize.x, imageHalfSize.y);
    
    return scaledImageHalfSize;
}
