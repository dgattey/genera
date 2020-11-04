//
//  MapRenderer.swift
//  Genera
//
//  Created by Dylan Gattey on 10/28/20.
//

import Metal
import MetalKit
import simd

/// Constants for this map renderer
private enum MapRendererConstant {
    
    /// Light blue background color
    static let backgroundColor = MTLClearColorMake(0.0, 0.5, 1.0, 1.0)
    
}

/// Renders a full map to the main Metal screen, using shaders defined in the generation delegate
class MapRenderer<GeneratorDataDelegateType: GeneratorDataDelegate>: NSObject, MTKViewDelegate {
    
    // MARK: - delegates

    weak var viewportChangeDelegate: ViewportChangeDelegate?
    weak var viewportDataDelegate: ViewportDataDelegate?
    weak var debugDelegate: DebugDelegate?
    private weak var generatorDataDelegate: GeneratorDataDelegateType?
    
    // MARK: - variables
    
    /// The view we're drawing into
    private let view: MTKView
    
    /// Main device we're using to draw
    private let mainDevice: MTLDevice
    
    /// Our list of drawing commands
    private let commandQueue: MTLCommandQueue
    
    /// Render pipeline we reuse every draw loop
    private let renderPipelineState: MTLRenderPipelineState
    
    /// This locks in reverse so we wait until the GPU has finished
    private let drawingSemaphore = DispatchSemaphore(value: 1)
    
    /// This keeps track of vertices for a given chunk
    private var vertexBuffers: Dictionary<Chunk, MTLBuffer> = Dictionary()
    
    /// Keeps track of current viewport data, passed into rendering
    private var viewportBufferData: [Float] = []
    
    // MARK: - initialization
    
    /// If the command queue or pipeline state fails to get created, this will fail
    init?(view: MTKView, device: MTLDevice, generatorDataDelegate: GeneratorDataDelegateType?) {
        // Create related objects
        guard let commandQueue = device.makeCommandQueue(),
              let dataDelegate = generatorDataDelegate,
              let renderPipelineState = MapRenderer.buildPipelineState(view: view, device: device, generatorDataDelegate: dataDelegate) else {
            return nil
        }
        
        // Config changes for the view itself to set it up right
        MapRenderer.configure(view: view, device: device)
        
        self.mainDevice = device
        self.view = view
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        self.generatorDataDelegate = generatorDataDelegate
        
        super.init()
    }
    
    /// Builds a render pipeline state object using the current device and our default shaders
    private static func buildPipelineState<T: GeneratorDataDelegate>(view: MTKView, device: MTLDevice, generatorDataDelegate: T) -> MTLRenderPipelineState? {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: generatorDataDelegate.shaders.vertex)
        let fragmentFunction = library?.makeFunction(name: generatorDataDelegate.shaders.fragment)

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.vertexBuffers[ShaderIndex.vertices.rawValue].mutability = .immutable
        
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
        view.clearColor = MapRendererConstant.backgroundColor
        view.enableSetNeedsDisplay = true
    }
    
    // MARK: - drawing functions
    
    /// Makes sure bytes are stored for the new user position viewport
    private func updateUserViewportBufferData(to viewport: MTLViewport) {
        viewportBufferData = [
            Float(viewport.originX),
            Float(viewport.originY),
            Float(viewport.width),
            Float(viewport.height)
        ]
        view.setNeedsDisplay(NSRect(x: viewport.originX, y: viewport.originY, width: viewport.width, height: viewport.height))
    }

    /// Draws the shapes as specified in all our chunked buffers (will loop over all chunks)
    private func drawShapes(to encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBytes(&viewportBufferData, length: viewportBufferData.count * MemoryLayout<Float>.stride, index: ShaderIndex.viewport.rawValue)

        for (_, vertexBuffer) in vertexBuffers {
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: ShaderIndex.vertices.rawValue)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: Size.verticesPerChunk )
        }
    }

    // MARK: - MTKViewDelegate
    
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
        let savedBuffer = vertexBuffers[chunk]
        let buffer: MTLBuffer
        if let savedBuffer = savedBuffer {
            buffer = savedBuffer
        } else {
            guard let size = generatorDataDelegate?.verticesBufferSize,
                  let vertexBuffer = mainDevice.makeBuffer(length: size, options: .storageModeManaged) else {
                assertionFailure("Couldn't create buffers")
                return
            }
            vertexBuffers[chunk] = vertexBuffer
            buffer = vertexBuffer
        }
        
        // Then dispatch to the background to populate them
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self,
                  let vertices = strongSelf.generatorDataDelegate?.vertices(for: chunk),
                  let stride = strongSelf.generatorDataDelegate?.stride else {
                assertionFailure("No \(chunk) set up yet or self missing: \(String(describing: self)) | \(String(describing: buffer))")
                return
            }
            var vertexPointer = buffer.contents()
            for item in vertices {
                vertexPointer.storeBytes(of: item, as: type(of: item))
                vertexPointer = vertexPointer + stride
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    assertionFailure("Couldn't capture self from main thread")
                    return
                }
                strongSelf.drawingSemaphore.signal()
                
                buffer.didModifyRange((0 ..< buffer.length))
                strongSelf.view.setNeedsDisplay(strongSelf.view.bounds)
                
                _ = strongSelf.drawingSemaphore.wait(timeout: DispatchTime.distantFuture)
            }
        }
        
    }
    
    /// Deletes data for a chunk
    func didDelete(chunk: Chunk) {
        // Delete the buffer
        vertexBuffers.removeValue(forKey: chunk)
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
