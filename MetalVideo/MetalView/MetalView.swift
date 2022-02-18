//
//  MetalView.swift
//  MetalVideo
//
//  Created by BYUNGWOOK JEONG on 2022/01/03.
//

import SwiftUI
import simd

struct MetalView: UIViewControllerRepresentable {
    let metalVC = MetalViewController()
    
    func makeUIViewController(context: Context) -> MetalViewController {
        let panGestureRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture(_:)))
        panGestureRecognizer.delegate = context.coordinator
        metalVC.view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture(_:)))
        pinchGestureRecognizer.delegate = context.coordinator
        metalVC.view.addGestureRecognizer(pinchGestureRecognizer)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture(_:)))
        rotationGestureRecognizer.delegate = context.coordinator
        metalVC.view.addGestureRecognizer(rotationGestureRecognizer)
        
        return metalVC
    }
    
    func updateUIViewController(_ uiViewController: MetalViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let metalView: MetalView
        var activeGestureRecognizers: [Set<UIGestureRecognizer>]!
        
        init(_ metalView: MetalView) {
            self.metalView = metalView
            activeGestureRecognizers = [Set<UIGestureRecognizer>](repeating: [], count: metalView.metalVC.objectCount)
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
        
        @objc func handleGesture(_ sender: UIGestureRecognizer) {
            let location = sender.location(in: metalView.metalVC.view)
            
            switch sender.state {
            case .began:
                for i in 0 ..< metalView.metalVC.objectCount {
                    if isInsideArea(viewHalfSize: metalView.metalVC.viewHalfSize,
                                    imageHalfSize: metalView.metalVC.imageHalfSizes[i],
                                    imageCenter: metalView.metalVC.imageCenters[i],
                                    translation: metalView.metalVC.translations[i],
                                    scale: metalView.metalVC.scales[i],
                                    rotation: metalView.metalVC.rotations[i],
                                    location: location) {
                        activeGestureRecognizers[i].insert(sender)
                    }
                }
                
                break
            case .ended:
                for i in 0 ..< metalView.metalVC.objectCount {
                    activeGestureRecognizers[i].remove(sender)
                }
                
                break
            case .changed:
                for i in 0 ..< metalView.metalVC.objectCount {
                    for gestureRecognizer in activeGestureRecognizers[i] {
                        if gestureRecognizer.responds(to: #selector(UIPanGestureRecognizer.translation(in:))) {
                            translate(gestureRecognizer as! UIPanGestureRecognizer, index: i)
                        } else if gestureRecognizer.responds(to: #selector(getter: UIPinchGestureRecognizer.scale)) {
                            scale(gestureRecognizer as! UIPinchGestureRecognizer, index: i)
                        } else if gestureRecognizer.responds(to: #selector(getter: UIRotationGestureRecognizer.rotation)) {
                            rotate(gestureRecognizer as! UIRotationGestureRecognizer, index: i)
                        }
                    }
                }
                    
                break
            default:
                break
            }
        }
        
        func translate(_ sender: UIPanGestureRecognizer, index: Int) {
            let translation = sender.translation(in: metalView.metalVC.view)
            let tx = Float(translation.x)
            let ty = Float(translation.y)
            metalView.metalVC.translations[index] += SIMD2<Float>(tx, ty)

            sender.setTranslation(CGPoint.zero, in: metalView.metalVC.view)
        }

        func scale(_ sender: UIPinchGestureRecognizer, index: Int) {
            let scale = sender.scale
            metalView.metalVC.scales[index] *= Float(scale)

            sender.scale = 1
        }

        func rotate(_ sender: UIRotationGestureRecognizer, index: Int) {
            let rotation = sender.rotation
            metalView.metalVC.rotations[index] += Float(rotation)

            sender.rotation = 0
        }
    }
}

