//
//  AffineTransform.h
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

#ifndef AffineTransform_h
#define AffineTransform_h

metal::float3x3 translationMatrix(float2 translation);
metal::float3x3 scaleMatrix(float scale);
metal::float3x3 rotationMatrix(float radian);

#endif /* AffineTransform_h */
