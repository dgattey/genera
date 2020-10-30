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
    static let maxBuffers = 3
}

// MARK: - Renderer Class

class Renderer: NSObject, MTKViewDelegate {
    
    private static let floatSize = MemoryLayout<simd_float1>.size
    
    private let view: MTKView
    private let mainDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private let generator: BasicGenerator
    private var currentViewport: MTLViewport
    
    private var vertexBuffers: [MTLBuffer] = []
    private var colorBuffers: [MTLBuffer] = []
    private var viewportBuffer: MTLBuffer?
    private var currentBuffer = 0
    
    private let inFlightSemaphore = DispatchSemaphore(value: Constant.maxBuffers)
    
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
        
        let viewportBuffer = device.makeBuffer(length: 2 * Renderer.floatSize, options: .storageModeShared)
        viewportBuffer?.label = "viewportBuffer"
        self.viewportBuffer = viewportBuffer
        
        super.init()
        
        // Build render buffers
        for bufferIndex in (0..<Constant.maxBuffers) {
            guard let vertexBuffer = device.makeBuffer(length: generator.verticesBufferSize, options: .storageModeShared),
                  let colorBuffer = device.makeBuffer(length: generator.colorsBufferSize, options: .storageModeShared) else {
                print("Couldn't create buffers at \(bufferIndex)")
                return
            }
            vertexBuffer.label = "vertexBuffer\(bufferIndex)"
            colorBuffer.label = "colorBuffer\(bufferIndex)"
            self.vertexBuffers.append(vertexBuffer)
            self.colorBuffers.append(colorBuffer)
        }
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
        descriptor.vertexBuffers[VertexAttribute.positions.rawValue].mutability = .immutable
        descriptor.vertexBuffers[VertexAttribute.colors.rawValue].mutability = .immutable
        descriptor.vertexBuffers[VertexAttribute.viewportSize.rawValue].mutability = .immutable
        
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
        let width = min(1500, max(simd_float1(size.width), 600))
        let height = min(1500, max(simd_float1(size.height), 600))
        guard let widthPointer = viewportBuffer?.contents() else {
            return
        }
        let heightPointer = widthPointer + Renderer.floatSize
        widthPointer.storeBytes(of: width, as: simd_float1.self)
        heightPointer.storeBytes(of: height, as: simd_float1.self)
    }
    
    // Updates state and draws something to the screen
    func draw(in view: MTKView) {
        // Start waiting so we don't do too much work
        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("No command buffer to work with")
            return
        }
        let semaphore = inFlightSemaphore
        commandBuffer.addCompletedHandler { _ in
            semaphore.signal()
        }
        
        // Get the buffers updated for the GPU to use below
        updateCurrentBuffers()
        
        // In the drawing loop below here - be quick!
        guard let descriptor = view.currentRenderPassDescriptor,
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
    
    // Advances current buffer and stores new data from vertices + colors
    private func updateCurrentBuffers() {
        currentBuffer = (currentBuffer + 1) % Constant.maxBuffers
        
        var vertexPointer = vertexBuffers[currentBuffer].contents()
        for item in generator.vertices {
            vertexPointer.storeBytes(of: item, as: simd_float1.self)
            vertexPointer = vertexPointer + Renderer.floatSize
        }
        
        var colorPointer = colorBuffers[currentBuffer].contents()
        for item in generator.colors {
            colorPointer.storeBytes(of: item, as: simd_float1.self)
            colorPointer = colorPointer + Renderer.floatSize
        }
    }
    
    // Draws the shapes as specified in our buffers
    private func drawShapes(to encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vertexBuffers[currentBuffer], offset: 0, index: VertexAttribute.positions.rawValue)
        encoder.setVertexBuffer(colorBuffers[currentBuffer], offset: 0, index: VertexAttribute.colors.rawValue)
        encoder.setVertexBuffer(viewportBuffer, offset: 0, index: VertexAttribute.viewportSize.rawValue)
        
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Tile.vertexCount * generator.tiles.count * Tile.polygonCount)
    }
    
    
}
