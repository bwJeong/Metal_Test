//
//  MetalViewController.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

import UIKit
import MetalKit

class MetalViewController: UIViewController {
    var viewHalfSize: SIMD2<Float>!
    var imageCenters: [SIMD2<Float>]!
    var imageHalfSizes: [SIMD2<Float>]!
    var translations: [SIMD2<Float>]!
    var scales: [Float]!
    var rotations: [Float]!
    var textures: [MTLTexture?]!
    var videoObjects: [VideoObject?]!
    let objectCount = 2
    
    var device: MTLDevice!
    private var metalLayer: CAMetalLayer!
    private var renderPipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    private var timer: CADisplayLink!
    private var renderer: Renderer!
    
    private var loopCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMetal()
        initRenderArguments()
    }
    
    private func initMetal() {
        // Set MTLDevice
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Cannot create MTLDevice!")
        }
        
        self.device = device
        
        // Set CAMetalLayer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.frame
        view.layer.addSublayer(metalLayer)
        
        // Set MTLRenderPipelineState
        guard let defaultLibrary = device.makeDefaultLibrary() else {
            fatalError("Cannot create MTLLibrary!")
        }
        
        let vertexProgram = defaultLibrary.makeFunction(name: "vertexShader")
        let fragmentProgram = defaultLibrary.makeFunction(name: "fragmentShader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            fatalError("Cannot create MTLRenderPipelineState!")
        }
        
        // Set MTLCommandQueue
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Cannot create MTLCommandQueue!")
        }
        
        self.commandQueue = commandQueue
        
        // Set CADisplayLink
        timer = CADisplayLink(target: self, selector: #selector(gameloop(_:)))
        timer.add(to: .main, forMode: .default)
        
        // Set Renderer
        renderer = Renderer(device: device)
    }
    
    private func initRenderArguments() {
        let videoObjectArray = [
            VideoObject(device: device, videoName: "Santa_Claus", videoType: "mp4"),
            VideoObject(device: device, videoName: "Chicken", videoType: "mp4")
        ]
        let imageCenterArray = [
            SIMD2<Float>(100, 100),
            SIMD2<Float>(150, 300)
        ]
        
        viewHalfSize = SIMD2<Float>(Float(view.frame.width / 2), Float(view.frame.height / 2))
        imageCenters = [SIMD2<Float>](repeating: SIMD2<Float>(0, 0), count: objectCount)
        imageHalfSizes = [SIMD2<Float>](repeating: SIMD2<Float>(0, 0), count: objectCount)
        translations = [SIMD2<Float>](repeating: SIMD2<Float>(0, 0), count: objectCount)
        scales = [Float](repeating: 1, count: objectCount)
        rotations = [Float](repeating: 0, count: objectCount)
        textures = [MTLTexture?](repeating: nil, count: objectCount)
        videoObjects = [VideoObject?](repeating: nil, count: objectCount)
        
        for i in 0 ..< objectCount {
            imageCenters[i] = imageCenterArray[i]
            imageHalfSizes[i] = SIMD2<Float>(Float(videoObjectArray[i].naturalSize.width) / 2,
                                             Float(videoObjectArray[i].naturalSize.height) / 2)
            textures[i] = videoObjectArray[i].texture
            videoObjects[i] = videoObjectArray[i]
        }
    }
    
    @objc private func gameloop(_ sender: CADisplayLink) {
        print(sender.timestamp, sender.duration)
        
        autoreleasepool {
            videoObjects.enumerated().forEach { index, videoObject in
                guard let videoObject = videoObject else { return }
                
                if loopCount % 60 == Int(round(videoObject.nextBufferCount)) % 60 {
                    videoObject.requestNextTexture()
                    textures[index] = videoObject.texture
                }
            }
            
            render()
        }
        
        loopCount += 1
    }
    
    private func render() {
        guard let drawable = metalLayer.nextDrawable() else { return }
        
        renderer.render(commandQueue: commandQueue,
                        renderPipelineState: renderPipelineState,
                        drawable: drawable,
                        viewHalfSize: &viewHalfSize,
                        imageCenters: &imageCenters,
                        imageHalfSizes: &imageHalfSizes,
                        translations: &translations,
                        scales: &scales,
                        rotations: &rotations,
                        textures: &textures)
    }
}
