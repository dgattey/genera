//
//  Renderer.swift
//  Land Shared
//
//  Created by Dylan Gattey on 10/28/20.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    
    private let mainView: MTKView
    private let mainDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    
    init?(mainView: MTKView, device: MTLDevice) {
        self.mainDevice = device
        self.mainView = mainView
        
        // Command queue setup
        guard let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        self.commandQueue = commandQueue
        
        // Config changes for the view itself to set it up right
        Renderer.configure(metalView: mainView, device: device)
        
        super.init()
    }
    
    // Configures the view itself once with everything it needs to start to render
    static func configure(metalView: MTKView, device: MTLDevice) {
        metalView.device = device
        metalView.clearColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)
        metalView.enableSetNeedsDisplay = true
    }
    
    // Called on every tick to update data
    private func updateGameState() {
    }
    
    // Called whenever the frame size changes to invalidate current draws
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        
    }
    
    // Updates state and draws something to the screen
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("Command buffer not set up")
            return
        }
        
        updateGameState()
        
        // Wait to grab the encoder until as late as possible
        guard let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            print("Render pass not set up correctly")
            return
        }
        
        // Done with drawing instructions
        encoder.endEncoding()
        
        // Draw to the screen itself
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        
        // We're done with frame itself, so let's commit what we've queued up
        commandBuffer.commit()
    }
    
    
}

// Generic matrix math utility functions
func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                         vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                         vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                         vector_float4(                  0,                   0,                   0, 1)))
}

func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                         vector_float4(0, 1, 0, 0),
                                         vector_float4(0, 0, 1, 0),
                                         vector_float4(translationX, translationY, translationZ, 1)))
}

func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
                                         vector_float4( 0, ys, 0,   0),
                                         vector_float4( 0,  0, zs, -1),
                                         vector_float4( 0,  0, zs * nearZ, 0)))
}

func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}
