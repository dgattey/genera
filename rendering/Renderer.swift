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
    private let generator: GeneratorProtocol
    private var currentViewport: MTLViewport
    
    private let vertexBuffer: MTLBuffer
    private let colorBuffer: MTLBuffer
    private let viewportBuffer: MTLBuffer
    
    // MARK: - initialization
    
    // If the command queue or pipeline state fails to get created, this will fail
    init?(view: MTKView, device: MTLDevice, generator: GeneratorProtocol) {
        // Create related objects
        guard let commandQueue = device.makeCommandQueue(),
              let renderPipelineState = Renderer.buildPipelineState(view: view, device: device) else {
            return nil
        }
        
        // Config changes for the view itself to set it up right
        Renderer.configure(view: view, device: device)
        
        let viewport = MTLViewport()
        
        self.mainDevice = device
        self.view = view
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        self.currentViewport = viewport
        self.generator = generator
        
        guard let vertexBuffer = device.makeBuffer(length: generator.verticesBufferSize, options: .storageModeManaged),
              let colorBuffer = device.makeBuffer(length: generator.colorsBufferSize, options: .storageModeManaged),
              let viewportBuffer = device.makeBuffer(length: 4 * Renderer.floatSize, options: .storageModeShared) else {
            assertionFailure("Buffers couldn't be allocated")
            return nil
        }
        self.vertexBuffer = vertexBuffer
        self.colorBuffer = colorBuffer
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
        descriptor.vertexBuffers[VertexAttribute.positions.rawValue].mutability = .immutable
        descriptor.vertexBuffers[VertexAttribute.colors.rawValue].mutability = .immutable
        descriptor.vertexBuffers[VertexAttribute.viewport.rawValue].mutability = .immutable
        
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
        currentViewport = Utility.viewport(byResizing: currentViewport, to: size)
        updateViewportBufferData()
    }
    
    // Updates state and draws something to the screen
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            print("No command buffer to work with")
            return
        }
        
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
    
    private func updateViewportBufferData() {
        var viewportPointer = viewportBuffer.contents()
        viewportPointer.storeBytes(of: Float(currentViewport.originX), as: Float.self)
        viewportPointer = viewportPointer + Renderer.floatSize
        viewportPointer.storeBytes(of: Float(currentViewport.originY), as: Float.self)
        viewportPointer = viewportPointer + Renderer.floatSize
        viewportPointer.storeBytes(of: Float(currentViewport.width), as: Float.self)
        viewportPointer = viewportPointer + Renderer.floatSize
        viewportPointer.storeBytes(of: Float(currentViewport.height), as: Float.self)
        view.setNeedsDisplay(NSRect(x: 0, y: 0, width: 1000, height: 1000))
    }
    
    // Draws the shapes as specified in our buffers
    private func drawShapes(to encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexAttribute.positions.rawValue)
        encoder.setVertexBuffer(colorBuffer, offset: 0, index: VertexAttribute.colors.rawValue)
        encoder.setVertexBuffer(viewportBuffer, offset: 0, index: VertexAttribute.viewport.rawValue)
        
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Tile.vertexCount * Tile.polygonCount * generator.chunkSize * generator.chunkSize )
    }
    
    
}

extension Renderer: GeneratorChangeDelegate {
    
    func didUpdateTiles(in chunk: Chunk) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            var vertexPointer = strongSelf.vertexBuffer.contents()
            for item in strongSelf.generator.vertices(for: chunk) {
                vertexPointer.storeBytes(of: item, as: Float.self)
                vertexPointer = vertexPointer + Renderer.floatSize
            }
            
            var colorPointer = strongSelf.colorBuffer.contents()
            for item in strongSelf.generator.colors(for: chunk) {
                colorPointer.storeBytes(of: item, as: Float.self)
                colorPointer = colorPointer + Renderer.floatSize
            }
            
            DispatchQueue.main.async {
                strongSelf.vertexBuffer.didModifyRange((0..<strongSelf.vertexBuffer.length))
                strongSelf.colorBuffer.didModifyRange((0..<strongSelf.colorBuffer.length))
                strongSelf.view.setNeedsDisplay(NSRect(x: 0, y: 0, width: 1, height: 1))
            }
        }
        
    }
    
}

extension Renderer: ViewportChangeDelegate {
    
    func pan(in direction: Direction) {
        currentViewport = Utility.viewport(byTranslating: currentViewport, inDirection: direction)
        updateViewportBufferData()
    }
    
}
