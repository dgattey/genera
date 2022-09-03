// GameCoordinator.swift
// Copyright (c) 2022 Dylan Gattey

import Combine
import Debug
import EngineCore
import Metal

/// Coordinates the game of a certain type of data, created from a Metal view and an optional debug delegate
public class GameCoordinator<ChunkDataProvider: ChunkDataProviderProtocol> {
    // MARK: variables

    /// Provides all data in the form of vertices and chunks for the other objects
    private let dataProvider: ChunkDataProvider

    /// Provides the shader data provider from the `dataProvider`
    public var shaderDataProvider: ChunkDataProvider.ShaderDataProviderType? {
        dataProvider.shaderDataProvider
    }

    /// Handles user changes to the viewport/translations/visibility of chunks
    private let viewportCoordinator: ViewportCoordinator<ChunkDataProvider>

    /// Coordinates loading and deleting chunks in response to user moving around. Also contains
    /// actual vertex data for use in rendering
    private let chunkCoordinator: ChunkCoordinator<ChunkDataProvider>

    /// Renders the content to the screen
    private let renderer: MapRenderer<ChunkDataProvider, ChunkDataProvider.ShaderDataProviderType>

    /// This gets set in init to a function that resizes the view
    private let resizeClosure: () -> Void

    // MARK: delegated delegates

    /// For logging things to the debugger
    public weak var debugger: DebugProtocol? {
        didSet {
            chunkCoordinator.debugger = debugger
            viewportCoordinator.debugger = debugger
            renderer.debugger = debugger
        }
    }

    // MARK: initialization

    /// Initialization will fail if Metal is missing or the renderer isn't
    /// created correctly. Otherwise, sets everything up.
    public init?(view: InteractableMTKView) {
        let dataProvider = ChunkDataProvider()
        let viewportCoordinator = ViewportCoordinator(initialSize: view.drawableSize, dataProvider: dataProvider)
        let chunkCoordinator = ChunkCoordinator(dataProvider: dataProvider)
        guard let defaultDevice = MTLCreateSystemDefaultDevice(),
              let renderer = MapRenderer<ChunkDataProvider, ChunkDataProvider.ShaderDataProviderType>(view: view,
                                                                                                      device: defaultDevice,
                                                                                                      dataProvider: dataProvider,
                                                                                                      chunkCoordinator: chunkCoordinator)
        else {
            assertionFailure("Game coordinator cannot be initialized")
            return nil
        }
        self.renderer = renderer
        self.chunkCoordinator = chunkCoordinator
        self.dataProvider = dataProvider
        self.viewportCoordinator = viewportCoordinator

        // So we can resize the view later
        resizeClosure = { renderer.mtkView(view, drawableSizeWillChange: view.drawableSize) }

        setupInitialDelegates(with: view)

        // If we have a publisher of shader data, remap it to RendererAction
        let mappedPublisher = shaderDataProvider?.asPublisher?.map { action -> RendererAction in
            switch action {
            case .changeValue:
                return .redrawMap
            }
        }
        mappedPublisher?.subscribe(renderer)
    }

    deinit {
        chunkCoordinator.shutdown()
    }

    /// Actually starts the coordination - resizes the interactable view to make sure
    /// we have size info, then starts map generation on a background thread
    public func start() {
        resizeClosure()
        DispatchQueue.global(qos: .utility).async(execute: chunkCoordinator.startMapGeneration)
    }

    /// Creates connections between the objects via delegate pattern
    private func setupInitialDelegates(with view: InteractableMTKView) {
        // User interaction delegates first
        view.delegate = renderer
        view.subscribe(viewportCoordinator)
        renderer.subscribe(viewportCoordinator)

        // Viewport data provider
        chunkCoordinator.viewportDataProvider = viewportCoordinator
        renderer.viewportDataProvider = viewportCoordinator

        // Chunk coordinator + viewport coordinator delegates
        chunkCoordinator.subscribe(renderer)
        viewportCoordinator.subscribe(renderer)
    }
}
