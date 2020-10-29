//
//  Renderer.swift
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    
    private let view: MTKView
    private let mainDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private var currentViewport: MTLViewport
    
    init?(view: MTKView, device: MTLDevice) {
        // Create related objects
        guard let commandQueue = device.makeCommandQueue(),
              let renderPipelineState = Renderer.buildPipelineState(view: view, device: device) else {
            return nil
        }
        
        // Config changes for the view itself to set it up right
        Renderer.configure(view: view, device: device)
        
        self.mainDevice = device
        self.view = view
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        self.currentViewport = viewport(from: CGSize.zero)
        super.init()
    }
    
    // Builds a render pipeline state object using the current device and our shader
    static func buildPipelineState(view: MTKView, device: MTLDevice) -> MTLRenderPipelineState? {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "BasicPipeline"
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        
        // Copy pixel format since this is a simple pipeline
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        // Make it!
        var stateObject: MTLRenderPipelineState?
        do {
            try stateObject = device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error)
        }
        return stateObject
    }
    
    // Configures the view itself once with everything it needs to start to render
    static func configure(view: MTKView, device: MTLDevice) {
        view.device = device
        view.clearColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)
        view.enableSetNeedsDisplay = true
    }
    
    // No-op, called on every tick to update data
    private func updateGameState() {}
    
    // Set the new viewport size for next draw pass
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        currentViewport = viewport(from: size)
    }
    
    // Updates state and draws something to the screen
    func draw(in view: MTKView) {
        updateGameState()

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            print("Error in drawing stage")
            return
        }
        // Start drawing
        encoder.setViewport(currentViewport)
        encoder.setRenderPipelineState(renderPipelineState)
        
        let positions: [Float] = [
             0.0,  250,
            -250, -250,
             250, -250
        ]
        let triBytes = mainDevice.makeBuffer(bytes: positions, length: positions.count * 32, options: .storageModeShared)
        let colors: [Float] = [
            1, 0, 0, 1,
            0, 1, 0, 1,
            0, 0, 1, 1
        ]
        let colorBytes = mainDevice.makeBuffer(bytes: colors, length: colors.count * 32, options: .storageModeShared)
        
        let viewportData: [Float] = [
            Float(currentViewport.width), Float(currentViewport.height)
        ]
        let viewportBytes = mainDevice.makeBuffer(bytes: viewportData, length: viewportData.count * 32, options: .storageModeShared)
        
        encoder.setVertexBuffer(triBytes, offset: 0, index: VertexAttribute.positions.rawValue)
        encoder.setVertexBuffer(colorBytes, offset: 0, index: VertexAttribute.colors.rawValue)
        encoder.setVertexBuffer(viewportBytes, offset: 0, index: VertexAttribute.viewportSize.rawValue)
       
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        // Done with drawing instructions
        encoder.endEncoding()
        
        // Draw to the screen itself
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        
        // We're done with commands for this frame, so commit what we've queued up
        commandBuffer.commit()
    }
    
    
}

// Convenience function for creating a Viewport from a regular CGSize
func viewport(from size: CGSize) -> MTLViewport {
    return MTLViewport(
        originX: 0.0,
        originY: 0.0,
        width: Double(size.width),
        height: Double(size.height),
        znear: 0.0,
        zfar: 1.0)
}
