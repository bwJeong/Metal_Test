//
//  Renderer.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

import MetalKit
import SwiftUI

class Renderer {
    private let device: MTLDevice
    private let vertexBuffer: MTLBuffer
    private let samplerState: MTLSamplerState?
    
    init(device: MTLDevice) {
        self.device = device
    
        // Set MTLBuffer
        let plane = Plane()
        
        guard let vertexBuffer = device.makeBuffer(bytes: plane.vertexData, length: plane.dataSize, options: []) else {
            fatalError("Cannot create MTLBuffer!")
        }
        
        self.vertexBuffer = vertexBuffer
        
        // Set MTLSamplerState
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
    }
    
    func render(commandQueue: MTLCommandQueue,
                renderPipelineState: MTLRenderPipelineState,
                drawable: CAMetalDrawable,
                viewHalfSize: inout SIMD2<Float>,
                imageCenters: inout [SIMD2<Float>],
                imageHalfSizes: inout [SIMD2<Float>],
                translations: inout [SIMD2<Float>],
                scales: inout [Float],
                rotations: inout [Float],
                textures: inout [MTLTexture?]) {
        // Set MTLRenderPassDescriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Set MTLCommandBuffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Cannot create MTLCommandBuffer!")
        }
        
        // Set MTLRenderCommandEncoder
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("Cannot create MTLRenderCommandEncoder!")
        }
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        let texturesRange = Range<Int>(0 ... textures.count - 1)
        renderCommandEncoder.setFragmentTextures(textures, range: texturesRange)
        
        renderCommandEncoder.setFragmentBytes(&viewHalfSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 0)
        renderCommandEncoder.setFragmentBytes(&imageCenters, length: MemoryLayout<SIMD2<Float>>.stride * imageCenters.count, index: 1)
        renderCommandEncoder.setFragmentBytes(&imageHalfSizes, length: MemoryLayout<SIMD2<Float>>.stride * imageHalfSizes.count, index: 2)
        renderCommandEncoder.setFragmentBytes(&translations, length: MemoryLayout<SIMD2<Float>>.stride * translations.count, index: 3)
        renderCommandEncoder.setFragmentBytes(&scales, length: MemoryLayout<Float>.stride * scales.count, index: 4)
        renderCommandEncoder.setFragmentBytes(&rotations, length: MemoryLayout<Float>.stride * rotations.count, index: 5)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderCommandEncoder.endEncoding()
        
        // Send command buffer to GPU
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
