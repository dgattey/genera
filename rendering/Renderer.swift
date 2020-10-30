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

// Constants for the renderer
private enum Constant {
    static let vertexFunction = "vertexShader"
    static let fragmentFunction = "fragmentShader"
    static let backgroundColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)
}

// MARK: - Renderer Class

class Renderer: NSObject, MTKViewDelegate {
    
    private let view: MTKView
    private let mainDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private var currentViewport: MTLViewport
    private let generator = BasicGenerator()
    
    // MARK: - initialization
    
    // If the command queue or pipeline state fails to get created, this will fail
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
        self.currentViewport = Utility.viewport(from: CGSize.zero)
        super.init()
    }
    
    // Builds a render pipeline state object using the current device and our default shaders
    private static func buildPipelineState(view: MTKView, device: MTLDevice) -> MTLRenderPipelineState? {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: Constant.vertexFunction)
        let fragmentFunction = library?.makeFunction(name: Constant.fragmentFunction)

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        var stateObject: MTLRenderPipelineState?
        do {
            try stateObject = device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print("Couldn't create render pipeline state object: \(error)")
            return nil
        }
        return stateObject
    }
    
    // Configures the view itself once with everything it needs to start to render
    private static func configure(view: MTKView, device: MTLDevice) {
        view.device = device
        view.clearColor = Constant.backgroundColor
        view.enableSetNeedsDisplay = true
    }
    
    // MARK: - MTKViewDelegate functions
    
    // Set the new viewport size for next draw pass
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        currentViewport = Utility.viewport(from: size)
    }
    
    // Updates state and draws something to the screen
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            print("Error in drawing stage")
            return
        }
        
        // Configure the encoder & draw to it
        encoder.setViewport(currentViewport)
        encoder.setRenderPipelineState(renderPipelineState)
        draw(to: encoder)
        encoder.endEncoding()
        
        // Draw to the screen itself and commit what we've enqueued
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
    
    // MARK: - drawing functions
    
    // Queues the sample triangle to the encoder
    private func draw(to encoder: MTLRenderCommandEncoder) {
        let vertices = generator.vertices
        print("Number of vertices: \(vertices.count / 2)")
        let verticesBytes = mainDevice.makeBuffer(bytes: vertices, length: vertices.count * 32, options: .storageModeShared)
        
        let colors = generator.colors
        print("Number of colors: \(colors.count / 4)")
        let colorBytes = mainDevice.makeBuffer(bytes: colors, length: colors.count * 32, options: .storageModeShared)
        
        let viewportData: [Float] = [
            Float(currentViewport.width), Float(currentViewport.height)
        ]
        print("Viewport size: \(viewportData)")
        let viewportBytes = mainDevice.makeBuffer(bytes: viewportData, length: viewportData.count * 32, options: .storageModeShared)
        
        encoder.setVertexBuffer(verticesBytes, offset: 0, index: VertexAttribute.positions.rawValue)
        encoder.setVertexBuffer(colorBytes, offset: 0, index: VertexAttribute.colors.rawValue)
        encoder.setVertexBuffer(viewportBytes, offset: 0, index: VertexAttribute.viewportSize.rawValue)
        
        (0..<vertices.count / Tile.vertexCount).forEach({ polygonIndex in
            encoder.drawPrimitives(type: .triangle, vertexStart: polygonIndex * Tile.vertexCount, vertexCount: Tile.vertexCount)
        })
        
        // Signal end of drawing pass
        print()
    }
    
    
}
