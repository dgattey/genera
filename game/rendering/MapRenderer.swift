//
//  MapRenderer.swift
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

import Metal
import MetalKit
import simd

/// Renders a full map to the main Metal screen, using shaders defined in the generation delegate
class MapRenderer: NSObject {
    
    // MARK: - constants
    
    /// Light blue background color
    private static let backgroundColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)
    
    // MARK: - variables

    weak var viewportChangeDelegate: ViewportChangeDelegate?
    weak var viewportDataDelegate: ViewportDataDelegate?
    weak var debugDelegate: DebugDelegate?
    
    private let view: MTKView
    private let mainDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private let generatorDataDelegate: GeneratorDataDelegate
    private let drawingSemaphore = DispatchSemaphore(value: 1)
    
    /// This keeps track of vertices and colors for a given chunk
    private var vertexAndColorBuffers: Dictionary<Chunk, (MTLBuffer, MTLBuffer)> = Dictionary()
    
    /// This keeps track of the user position viewport for use in rendering
    private let userPositionViewportBuffer: MTLBuffer
    
    // MARK: - initialization
    
    /// If the command queue or pipeline state fails to get created, this will fail
    init?(view: MTKView, device: MTLDevice, generatorDataDelegate: GeneratorDataDelegate) {

        // Create related objects
        guard let commandQueue = device.makeCommandQueue(),
              let renderPipelineState = MapRenderer.buildPipelineState(view: view, device: device, generatorDataDelegate: generatorDataDelegate) else {
            return nil
        }
        
        // Config changes for the view itself to set it up right
        MapRenderer.configure(view: view, device: device)
        
        self.mainDevice = device
        self.view = view
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        self.generatorDataDelegate = generatorDataDelegate
        
        guard let userPositionViewportBuffer = device.makeBuffer(length: Size.viewportGrouping * Size.datum, options: .storageModeShared) else {
            assertionFailure("Viewport buffer couldn't be allocated")
            return nil
        }
        self.userPositionViewportBuffer = userPositionViewportBuffer
        
        super.init()
    }
    
    /// Builds a render pipeline state object using the current device and our default shaders
    private static func buildPipelineState(view: MTKView, device: MTLDevice, generatorDataDelegate: GeneratorDataDelegate) -> MTLRenderPipelineState? {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: generatorDataDelegate.shaders.vertex)
        let fragmentFunction = library?.makeFunction(name: generatorDataDelegate.shaders.fragment)

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.vertexBuffers[ShaderIndex.positions.rawValue].mutability = .immutable
        descriptor.vertexBuffers[ShaderIndex.colors.rawValue].mutability = .immutable
        descriptor.vertexBuffers[ShaderIndex.viewport.rawValue].mutability = .immutable
        
        var stateObject: MTLRenderPipelineState?
        do {
            try stateObject = device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            assertionFailure("Couldn't create render pipeline state object: \(error)")
            return nil
        }
        return stateObject
    }
    
    //. Configures the view itself once with everything it needs to start to render
    private static func configure(view: MTKView, device: MTLDevice) {
        view.device = device
        view.clearColor = MapRenderer.backgroundColor
        view.enableSetNeedsDisplay = true
    }
    
    // MARK: - drawing functions
    
    /// Makes sure bytes are stored for the new user position viewport
    private func updateUserViewportBufferData(to viewport: MTLViewport) {
        var pointer = userPositionViewportBuffer.contents()
        pointer.storeBytes(of: Float(viewport.originX), as: Float.self)
        pointer = pointer + Size.datum
        pointer.storeBytes(of: Float(viewport.originY), as: Float.self)
        pointer = pointer + Size.datum
        pointer.storeBytes(of: Float(viewport.width), as: Float.self)
        pointer = pointer + Size.datum
        pointer.storeBytes(of: Float(viewport.height), as: Float.self)
        view.setNeedsDisplay(NSRect(x: viewport.originX, y: viewport.originY, width: viewport.width, height: viewport.height))
    }

    /// Draws the shapes as specified in all our chunked buffers (will loop over all chunks)
    private func drawShapes(to encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(userPositionViewportBuffer, offset: 0, index: ShaderIndex.viewport.rawValue)
        
        for (_, (vertexBuffer, colorBuffer)) in vertexAndColorBuffers {
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: ShaderIndex.positions.rawValue)
            encoder.setVertexBuffer(colorBuffer, offset: 0, index: ShaderIndex.colors.rawValue)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Size.verticesPerChunk )
        }
    }
}

// MARK: - MTKViewDelegate

extension MapRenderer: MTKViewDelegate {
    
    /// Tell our change delegate we've resized
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportChangeDelegate?.resizeViewport(to: size)
    }
    
    /// Updates map state and draws it to the screen
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let viewport = viewportDataDelegate?.currentViewport else {
            assertionFailure("No command buffer to work with")
            return
        }
        
        // Block the semaphore while drawing so we don't update out of sync
        _ = drawingSemaphore.wait(timeout: DispatchTime.distantFuture)
        let semaphore = drawingSemaphore
        commandBuffer.addCompletedHandler { _ in
            semaphore.signal()
        }
        
        // In the drawing loop below here - be quick!
        guard let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            assertionFailure("Error in drawing stage")
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
    
    /// On a background thread, copies all data to the buffers, then set needs display for the chunk.
    func didGenerate(chunk: Chunk) {
        // Create the buffers if they don't exist, on the main thread
        let savedBuffers = vertexAndColorBuffers[chunk]
        let buffers: (MTLBuffer, MTLBuffer)
        if let savedBuffers = savedBuffers {
            buffers = savedBuffers
        } else {
            guard let vertexBuffer = mainDevice.makeBuffer(length: BufferSize.chunkVertices, options: .storageModeManaged),
                  let colorBuffer = mainDevice.makeBuffer(length: BufferSize.chunkColors, options: .storageModeManaged) else {
                assertionFailure("Couldn't create buffers")
                return
            }
            vertexAndColorBuffers[chunk] = (vertexBuffer, colorBuffer)
            buffers = (vertexBuffer, colorBuffer)
        }
        
        // Then dispatch to the background to populate them
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                assertionFailure("No \(chunk) set up yet or self missing: \(String(describing: self)) | \(String(describing: buffers))")
                return
            }
            // TODO: @dgattey make buffers not a tuple (real struct)
            var vertexPointer = buffers.0.contents()
            for item in strongSelf.generatorDataDelegate.vertices(for: chunk) {
                vertexPointer.storeBytes(of: item, as: Float.self)
                vertexPointer = vertexPointer + Size.datum
            }
            
            var colorPointer = buffers.1.contents()
            for item in strongSelf.generatorDataDelegate.colors(for: chunk) {
                colorPointer.storeBytes(of: item, as: Float.self)
                colorPointer = colorPointer + Size.datum
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    assertionFailure("Couldn't capture self from main thread")
                    return
                }
                strongSelf.drawingSemaphore.signal()
                
                buffers.0.didModifyRange((0 ..< buffers.0.length))
                buffers.1.didModifyRange((0 ..< buffers.1.length))
                // TODO: @dgattey make this a real size - this doesn't work...
                strongSelf.view.setNeedsDisplay(strongSelf.view.bounds)
                
                _ = strongSelf.drawingSemaphore.wait(timeout: DispatchTime.distantFuture)
            }
        }
        
    }
    
    /// Deletes data for a chunk
    func didDelete(chunk: Chunk) {
        // Delete the buffers
        vertexAndColorBuffers.removeValue(forKey: chunk)
        drawingSemaphore.signal()
        // TODO: @dgattey make this a real size - this doesn't work...
        view.setNeedsDisplay(view.bounds)
        _ = drawingSemaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    /// Updates viewport buffer data with the new viewport info
    func didUpdateUserPosition(to viewport: MTLViewport) {
        updateUserViewportBufferData(to: viewport)
    }
    
}
