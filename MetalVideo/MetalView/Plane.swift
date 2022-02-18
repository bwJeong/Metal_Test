//
//  Plane.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

struct Plane {
    let vertexData: [Float]
    let dataSize: Int
    
    init() {
        vertexData = [
            1.0, 1.0, 0.0,
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0,
            1.0, 1.0, 0.0,
            -1.0, 1.0, 0.0,
            -1.0, -1.0, 0.0
        ]
        
        dataSize = vertexData.count * MemoryLayout<Float>.stride
    }
}
