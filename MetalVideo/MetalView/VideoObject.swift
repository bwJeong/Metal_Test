//
//  VideoObject.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

import AVFoundation
import simd

class VideoObject {
    private let device: MTLDevice
    let videoName: String
    let videoType: String
    
    private var asset: AVAsset!
    private var reader: AVAssetReader!
    private var track: AVAssetTrack!
    private var readerTrackOutput: AVAssetReaderTrackOutput!
    private var pixelBuffer: CVPixelBuffer?
    private var textureCache: CVMetalTextureCache!
    
    var naturalSize: CGSize!
    var texture: MTLTexture?
    var frameCount: Int!
    var nextBufferCount: Float = 0
    
    init(device: MTLDevice, videoName: String, videoType: String) {
        self.device = device
        self.videoName = videoName
        self.videoType = videoType
        
        initReader()
    }
    
    private func initReader() {
        // Set AVAsset
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoType) else {
            fatalError("Cannot open the video!")
        }
        
        asset = AVAsset(url: url)
        
        // Set AVAssetReader
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            fatalError("Cannot create AVAssetReader!")
        }
        
        // Set AVAssetTrack
        track = asset.tracks(withMediaType: AVMediaType.video)[0]
        naturalSize = track.naturalSize
        frameCount = Int(600 / round(track.nominalFrameRate))
        
        // Set AVAssetReaderTrackOutput
        let outputSettings: [String: Any] = [
            String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA),
            String(kCVPixelBufferMetalCompatibilityKey): true
        ]
        
        readerTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        
        // Set CVMetalTextureCache
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache) == kCVReturnSuccess else {
            fatalError("Cannot allocate texture cache!")
        }
        
        // Start AVAssetReader
        reader.add(readerTrackOutput)
        reader.startReading()
    }
    
    func requestNextTexture() {
        guard let sampleBuffer = readerTrackOutput.copyNextSampleBuffer() else {
            initReader()
            return
        }
        
        pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        guard let pixelBuffer = pixelBuffer else { return }
        
        let w = CVPixelBufferGetWidth(pixelBuffer)
        let h = CVPixelBufferGetHeight(pixelBuffer)
        
        var cvMetalTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, .bgra8Unorm, w, h, 0, &cvMetalTexture)
        
        guard let unwrappedCVMetalTexture = cvMetalTexture else {
            print("CVMetalTexture is nil!")
            
            return
        }
        
        texture = CVMetalTextureGetTexture(unwrappedCVMetalTexture)
        
        nextBufferCount += Float(frameCount) / 10
    }
}
