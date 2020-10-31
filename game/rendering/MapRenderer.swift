//
//  MapRenderer.swift
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

// Our platform independent MapRenderer class

import Metal
import MetalKit
import simd

/**
 Renders a full map to the main Metal screen, using the SimpleShaders
 */
class MapRenderer: NSObject {
    // Size of a float for layout calculations
    private static let floatSize = MemoryLayout<Float>.size
    
    // Matches name of vertex shader in SimpleShaders
    private static let vertexFunction = "simpleVertexShader"
    
    // Matches name of fragment shader in SimpleShaders
    private static let fragmentFunction = "simpleFragmentShader"
    
    // Just a simple background color
    private static let backgroundColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)

    weak var viewportChangeDelegate: ViewportChangeDelegate?
    weak var viewportDataDelegate: ViewportDataDelegate?
    
    private let view: MTKView
    private let mainDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private let generatorDataDelegate: GeneratorDataDelegate
    
    private var vertexAndColorBuffers: Dictionary<Chunk, (MTLBuffer, MTLBuffer)> = Dictionary()
    private let viewportBuffer: MTLBuffer
    
    // MARK: - initialization
    
    // If the command queue or pipeline state fails to get created, this will fail
    init?(view: MTKView, device: MTLDevice, generatorDataDelegate: GeneratorDataDelegate) {
        // Create related objects
        guard let commandQueue = device.makeCommandQueue(),
              let renderPipelineState = MapRenderer.buildPipelineState(view: view, device: device) else {
            return nil
        }
        
        // Config changes for the view itself to set it up right
        MapRenderer.configure(view: view, device: device)
        
        self.mainDevice = device
        self.view = view
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        self.generatorDataDelegate = generatorDataDelegate
        
        guard let viewportBuffer = device.makeBuffer(length: 4 * MapRenderer.floatSize, options: .storageModeShared) else {
            assertionFailure("Viewport buffer couldn't be allocated")
            return nil
        }
        self.viewportBuffer = viewportBuffer
        
        super.init()
    }
    
    // Builds a render pipeline state object using the current device and our default shaders
    private static func buildPipelineState(view: MTKView, device: MTLDevice) -> MTLRenderPipelineState? {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: MapRenderer.vertexFunction)
        let fragmentFunction = library?.makeFunction(name: MapRenderer.fragmentFunction)

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.vertexBuffers[SimpleShaderIndex.positions.rawValue].mutability = .immutable
        descriptor.vertexBuffers[SimpleShaderIndex.colors.rawValue].mutability = .immutable
        descriptor.vertexBuffers[SimpleShaderIndex.viewport.rawValue].mutability = .immutable
        
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
        view.clearColor = MapRenderer.backgroundColor
        view.enableSetNeedsDisplay = true
    }
    
    // MARK: - drawing functions
    
    private func updateViewportBufferData(to viewport: MTLViewport) {
        var viewportPointer = viewportBuffer.contents()
        viewportPointer.storeBytes(of: Float(viewport.originX), as: Float.self)
        viewportPointer = viewportPointer + MapRenderer.floatSize
        viewportPointer.storeBytes(of: Float(viewport.originY), as: Float.self)
        viewportPointer = viewportPointer + MapRenderer.floatSize
        viewportPointer.storeBytes(of: Float(viewport.width), as: Float.self)
        viewportPointer = viewportPointer + MapRenderer.floatSize
        viewportPointer.storeBytes(of: Float(viewport.height), as: Float.self)
        view.setNeedsDisplay(NSRect(x: viewport.originX, y: viewport.originY, width: viewport.width, height: viewport.height))
    }

    // Draws the shapes as specified in all our chunked buffers
    private func drawShapes(to encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(viewportBuffer, offset: 0, index: SimpleShaderIndex.viewport.rawValue)
        
        for (_, (vertexBuffer, colorBuffer)) in vertexAndColorBuffers {
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: SimpleShaderIndex.positions.rawValue)
            encoder.setVertexBuffer(colorBuffer, offset: 0, index: SimpleShaderIndex.colors.rawValue)
            
            let vertexCount = Tile.vertexCount * Tile.polygonCount * generatorDataDelegate.chunkSize * generatorDataDelegate.chunkSize
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount )
        }
    }
}

// MARK: - MTKViewDelegate

extension MapRenderer: MTKViewDelegate {
    
    // Set the new viewport size for next draw pass
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportChangeDelegate?.resizeViewport(to: size)
    }
    
    // Updates state and draws something to the screen
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let viewport = viewportDataDelegate?.untranslatedViewport else {
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
        encoder.setViewport(viewport)
        encoder.setRenderPipelineState(renderPipelineState)
        drawShapes(to: encoder)
        encoder.endEncoding()
        
        // Draw to the screen itself and commit what we've enqueued
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
}

// MARK: - MapUpdateDelegate

extension MapRenderer: MapUpdateDelegate {
    
    /**
     On a background thread, copies all data to the buffers, then set needs display for the chunk
     */
    func didUpdateTiles(in chunk: Chunk) {
        // Create the buffers if they don't exist
        if (vertexAndColorBuffers[chunk] == nil) {
            guard let vertexBuffer = mainDevice.makeBuffer(length: generatorDataDelegate.verticesBufferSize, options: .storageModeManaged),
                  let colorBuffer = mainDevice.makeBuffer(length: generatorDataDelegate.colorsBufferSize, options: .storageModeManaged) else {
                assertionFailure("Couldn't create buffers")
                return
            }
            vertexAndColorBuffers[chunk] = (vertexBuffer, colorBuffer)
        }
        
        // Then dispatch to the background to populate them
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self,
                  let buffers = strongSelf.vertexAndColorBuffers[chunk] else {
                print("No buffer set up yet")
                return
            }
            // TODO: @dgattey make buffers not a tuple (real struct)
            var vertexPointer = buffers.0.contents()
            for item in strongSelf.generatorDataDelegate.vertices(for: chunk) {
                vertexPointer.storeBytes(of: item, as: Float.self)
                vertexPointer = vertexPointer + MapRenderer.floatSize
            }
            
            var colorPointer = buffers.1.contents()
            for item in strongSelf.generatorDataDelegate.colors(for: chunk) {
                colorPointer.storeBytes(of: item, as: Float.self)
                colorPointer = colorPointer + MapRenderer.floatSize
            }
            
            DispatchQueue.main.async {
                buffers.0.didModifyRange((0 ..< buffers.0.length))
                buffers.1.didModifyRange((0 ..< buffers.1.length))
                // TODO: @dgattey make this a real size
                strongSelf.view.setNeedsDisplay(NSRect(x: 0, y: 0, width: 1, height: 1))
            }
        }
        
    }
    
    /**
     Updates viewport buffer data with the new viewport info
     */
    func didUpdateViewport(to viewport: MTLViewport) {
        updateViewportBufferData(to: viewport)
    }
    
}
