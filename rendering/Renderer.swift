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
    
    private static let floatSize = MemoryLayout<Float>.size
    
    private let view: MTKView
    private let mainDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private let generator: BasicGenerator
    private let verticesBytes: MTLBuffer?
    private let colorsBytes: MTLBuffer?
    private var currentViewport: MTLViewport
    
    private var viewportBuffer: MTLBuffer?
    private var currentBuffer = 0
    
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
        
        let generator = BasicGenerator()
        let viewport = Utility.viewport(from: CGSize.zero)
        
        self.generator = generator
        self.mainDevice = device
        self.view = view
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        self.currentViewport = viewport
        
        // Build render buffers
        self.verticesBytes = Renderer.buildBuffer(device: device, data: generator.vertices)
        self.colorsBytes = Renderer.buildBuffer(device: device, data: generator.colors)
        let viewportBuffer = device.makeBuffer(length: 2 * Renderer.floatSize, options: .storageModeShared)
        viewportBuffer?.label = "viewportBuffer"
        self.viewportBuffer = viewportBuffer
        
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
    
    // Creates an MTLBuffer from some float data. Assumes 4x the data count
    private static func buildBuffer(device: MTLDevice, data: [Float]) -> MTLBuffer? {
        return device.makeBuffer(bytes: data, length: data.count * 4, options: .storageModeShared)
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
        let width = min(1500, max(Float(size.width), 600))
        let height = min(1500, max(Float(size.height), 600))
        let widthPointer = viewportBuffer?.contents()
        let heightPointer = widthPointer?.advanced(by: Renderer.floatSize)
        widthPointer?.storeBytes(of: width, as: Float.self)
        heightPointer?.storeBytes(of: height, as: Float.self)
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
        drawShapes(to: encoder)
        encoder.endEncoding()
        
        // Draw to the screen itself and commit what we've enqueued
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
    
    // MARK: - drawing functions
    
    // Draws the shapes as specified in our buffers
    private func drawShapes(to encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(verticesBytes, offset: 0, index: VertexAttribute.positions.rawValue)
        encoder.setVertexBuffer(colorsBytes, offset: 0, index: VertexAttribute.colors.rawValue)
        encoder.setVertexBuffer(viewportBuffer, offset: 0, index: VertexAttribute.viewportSize.rawValue)
        
        (0..<generator.tiles.count * Tile.polygonCount).forEach({ polygonIndex in
            encoder.drawPrimitives(type: .triangle, vertexStart: polygonIndex * Tile.vertexCount, vertexCount: Tile.vertexCount)
        })
    }
    
    
}
