// MapRenderer.swift
// Copyright (c) 2022 Dylan Gattey

import Combine
import Debug
import EngineCore
import EngineData
import Metal
import MetalKit
import simd

/// Renders a full map to the main Metal screen, using shaders defined in the generation delegate
class MapRenderer<ChunkDataProvider: ChunkDataProviderProtocol,
    ShaderDataProvider: ShaderDataProviderProtocol>: NSObject, MTKViewDelegate
{
    // MARK: - delegates

    weak var viewportDataProvider: ViewportDataProvider?
    weak var debugger: DebugProtocol?

    /// Publishes actions to anyone who listens
    private let publisher = PassthroughSubject<ViewportAction, Never>()

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
    private var vertexBuffers: [Chunk: MTLBuffer] = Dictionary()

    /// Keeps track of current viewport data, passed into rendering
    private var viewportBufferData: ViewportData

    /// Provides most data for this renderer
    private weak var dataProvider: ChunkDataProvider?

    /// Provides chunk data for this renderer
    private weak var chunkCoordinator: ChunkCoordinator<ChunkDataProvider>?

    // MARK: - initialization

    /// If the command queue or pipeline state fails to get created, this will fail
    init?(view: MTKView,
          device: MTLDevice,
          dataProvider: ChunkDataProvider?,
          chunkCoordinator: ChunkCoordinator<ChunkDataProvider>)
    {
        // Create related objects
        guard let commandQueue = device.makeCommandQueue(),
              let shaders = dataProvider?.shaders,
              let renderPipelineState = MapRenderer.buildPipelineState(view: view, device: device, shaders: shaders)
        else {
            return nil
        }

        // Config changes for the view itself to set it up right
        MapRenderer.configure(view: view, device: device)

        mainDevice = device
        self.view = view
        let scaleFactor = view.drawableSize / view.bounds.size
        viewportBufferData = ViewportData(origin: view.bounds.origin, size: view.bounds.size, scaleFactor: scaleFactor)
        self.commandQueue = commandQueue
        self.renderPipelineState = renderPipelineState
        self.dataProvider = dataProvider
        self.chunkCoordinator = chunkCoordinator

        super.init()
    }

    /// Builds a render pipeline state object using the current device and our default shaders
    private static func buildPipelineState(view: MTKView, device: MTLDevice,
                                           shaders: (vertex: String, fragment: String)) -> MTLRenderPipelineState?
    {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: shaders.vertex)
        let fragmentFunction = library?.makeFunction(name: shaders.fragment)

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.vertexBuffers[ShaderIndex.vertices.rawValue].mutability = .immutable

        var stateObject: MTLRenderPipelineState?
        do {
            try stateObject = device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            assertionFailure("Couldn't create render pipeline state object: \(error)")
            return nil
        }
        return stateObject
    }

    // . Configures the view itself once with everything it needs to start to render
    private static func configure(view: MTKView, device: MTLDevice) {
        view.device = device
        view.enableSetNeedsDisplay = true
        guard let backgroundColor = view.layer?.backgroundColor?.components,
              backgroundColor.count == 4
        else {
            return
        }
        view.clearColor = MTLClearColor(red: Double(backgroundColor[0]),
                                        green: Double(backgroundColor[1]),
                                        blue: Double(backgroundColor[2]),
                                        alpha: Double(backgroundColor[3]))
    }

    // MARK: - drawing functions

    /// Marks the view as should be redrawn at the next loop
    private func redrawView() {
        drawingSemaphore.signal()
        view.setNeedsDisplay(view.bounds)
        _ = drawingSemaphore.wait(timeout: DispatchTime.distantFuture)
    }

    /// Makes sure bytes are stored for the new user position viewport, scaling by the view's scale factor so we're
    /// drawing the same thing consistently on any screen
    private func updateUserViewportBufferData(to viewport: MTLViewport, inDrawableSize drawableSize: CGSize) {
        let scaleFactor = drawableSize / view.bounds.size
        viewportBufferData = ViewportData(viewport, scaleFactor: scaleFactor)
        debugger?.subject(for: .viewportBufferData).send(viewportBufferData)
        redrawView()
    }

    /// Draws the shapes as specified in all our chunked buffers (will loop over all chunks)
    private func drawShapes(to encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBytes(&viewportBufferData,
                               length: MemoryLayout<ViewportData>.stride,
                               index: ShaderIndex.viewport.rawValue)

        for (_, vertexBuffer) in vertexBuffers {
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: ShaderIndex.vertices.rawValue)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0,
                                   vertexCount: ChunkDataProvider.ChunkDataType.verticesPerChunk)
        }
    }

    /// Adds `ShaderDataProviderProtocol` content to the encoder
    private func addShaderConfigData(to encoder: MTLRenderCommandEncoder) {
        guard let shaderDataProvider = dataProvider?.shaderDataProvider else {
            // No data if we have no provider for it
            return
        }
        var shaderConfigBufferData = shaderDataProvider.configData
        var shaderBiomeBufferData = shaderDataProvider.allBiomes
        encoder.setFragmentBytes(&shaderConfigBufferData,
                                 length: MemoryLayout<ShaderDataProvider.ShaderDataType>.stride,
                                 index: ShaderIndex.configData.rawValue)
        encoder.setFragmentBytes(&shaderBiomeBufferData,
                                 length: shaderBiomeBufferData.count * MemoryLayout<Biome>.stride,
                                 index: ShaderIndex.biomeData.rawValue)
    }

    // MARK: - MTKViewDelegate

    /// Tell our change delegate we've resized
    func mtkView(_: MTKView, drawableSizeWillChange size: CGSize) {
        publisher.send(.resizeViewport(to: size))
    }

    /// Updates map state and draws it to the screen
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let viewport = viewportDataProvider?.currentViewport
        else {
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
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            assertionFailure("Error in drawing stage")
            return
        }

        // Configure the encoder & draw to it
        encoder.setViewport(viewport)
        encoder.setRenderPipelineState(renderPipelineState)
        addShaderConfigData(to: encoder)
        drawShapes(to: encoder)
        encoder.endEncoding()

        // Draw to the screen itself and commit what we've enqueued
        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
}

// MARK: - Publisher

extension MapRenderer: Publisher {
    public typealias Output = ViewportAction
    public typealias Failure = Never

    /// Connect the built-in publisher to the subscriber sent
    public func receive<S>(subscriber: S)
        where S: Subscriber,
        MapRenderer.Failure == S.Failure,
        MapRenderer.Output == S.Input
    {
        publisher.subscribe(subscriber)
    }
}

// MARK: - Subscriber

/// Subscribes the map renderer to a chunk coordinator's actions
extension MapRenderer: Subscriber {
    typealias Input = RendererAction

    /// Request unlimited items
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    /// Delegate to the right built in function
    func receive(_ action: RendererAction) -> Subscribers.Demand {
        switch action {
        case let .evictChunk(chunk):
            deleteChunk(chunk)
        case let .generateChunk(chunk):
            createChunk(chunk)
        case let .updateUserPosition(to: userPosition, inDrawableSize: drawableSize):
            updateUserViewportBufferData(to: userPosition, inDrawableSize: drawableSize)
        case let .updateVisibleRegion(to: region):
            updateVisibleRegion(to: region)
        case .redrawMap:
            redrawView()
        }
        return .none
    }

    /// No-op
    func receive(completion _: Subscribers.Completion<Never>) {}

    /// On a background thread, copies all data to the buffers, then set needs display for the chunk.
    private func createChunk(_ chunk: Chunk) {
        // Create the buffers if they don't exist, on the main thread
        let savedBuffer = vertexBuffers[chunk]
        let buffer: MTLBuffer
        if let savedBuffer = savedBuffer {
            buffer = savedBuffer
        } else {
            let length = ChunkDataProvider.ChunkDataType.verticesBufferSize
            guard let vertexBuffer = mainDevice.makeBuffer(length: length, options: .storageModeManaged) else {
                assertionFailure("Couldn't create buffers")
                return
            }
            vertexBuffers[chunk] = vertexBuffer
            buffer = vertexBuffer
        }

        // Then dispatch to the background to populate them
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let stride = ChunkDataProvider.ChunkDataType.stride
            guard let strongSelf = self,
                  let vertices = strongSelf.chunkCoordinator?.vertices(from: chunk)
            else {
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
                    return
                }
                strongSelf.drawingSemaphore.signal()

                buffer.didModifyRange(0 ..< buffer.length)
                strongSelf.view.setNeedsDisplay(strongSelf.view.bounds)

                _ = strongSelf.drawingSemaphore.wait(timeout: DispatchTime.distantFuture)
            }
        }
    }

    /// Deletes data for the chunk by deleting the vertex buffer's value
    private func deleteChunk(_ chunk: Chunk) {
        vertexBuffers.removeValue(forKey: chunk)
        redrawView()
    }

    /// Forwards to the chunk coordinator
    private func updateVisibleRegion(to visibleRegion: ChunkRegion) {
        chunkCoordinator?.handle(updatedVisibleRegion: visibleRegion)
    }
}
