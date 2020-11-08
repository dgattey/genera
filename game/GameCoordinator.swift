//
//  GameCoordinator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import MetalKit

/// Coordinates the game of a certain type of data, created from a Metal view and an optional debug delegate
class GameCoordinator<ChunkDataProviderType: ChunkDataProvider,
                      ShaderDataProviderType: ShaderDataProvider> {
    
    // MARK: variables
    
    /// Provides all data in the form of vertices and chunks for the other objects
    private let dataProvider: ChunkDataProviderType
    
    /// Handles user changes to the viewport/translations/visibility of chunks
    private let viewportCoordinator: ViewportCoordinator<ChunkDataProviderType>
    
    /// Coordinates loading and deleting chunks in response to user moving around. Also contains
    /// actual vertex data for use in rendering
    private let chunkCoordinator: ChunkCoordinator<ChunkDataProviderType>
    
    /// Renders the content to the screen
    private let renderer: MapRenderer<ChunkDataProviderType, ShaderDataProviderType>
    
    /// This gets set in init to a function that resizes the view
    private let resizeClosure: () -> Void
    
    // MARK: delegated delegates
    
    /// For logging things to the debug delegate
    weak var debugDelegate: DebugDelegate? {
        didSet {
            renderer.debugDelegate = debugDelegate
            chunkCoordinator.debugDelegate = debugDelegate
            viewportCoordinator.debugDelegate = debugDelegate
        }
    }
    
    /// For querying for data from the shader data provider (comes from another source)
    weak var shaderDataProvider: ShaderDataProviderType? {
        didSet {
            renderer.shaderDataProvider = shaderDataProvider
        }
    }
    
    // MARK: initialization
    
    /// Initialization will fail if Metal is missing or the renderer isn't
    /// created correctly. Otherwise, sets everything up.
    init?(view: InteractableViewProtocol) {
        let dataProvider = ChunkDataProviderType()
        let viewportCoordinator = ViewportCoordinator(initialSize: view.drawableSize, dataProvider: dataProvider)
        let chunkCoordinator = ChunkCoordinator(dataProvider: dataProvider)
        guard let defaultDevice = MTLCreateSystemDefaultDevice(),
              let renderer = MapRenderer<ChunkDataProviderType, ShaderDataProviderType>(
                view: view,
                device: defaultDevice,
                dataProvider: dataProvider,
                chunkCoordinator: chunkCoordinator) else {
            assertionFailure("Game coordinator cannot be initialized")
            return nil
        }
        self.renderer = renderer
        self.chunkCoordinator = chunkCoordinator
        self.dataProvider = dataProvider
        self.viewportCoordinator = viewportCoordinator
        
        // So we can resize the view later
        self.resizeClosure = { renderer.mtkView(view, drawableSizeWillChange: view.drawableSize) }
        
        setupInitialDelegates(with: view)
    }
    
    /// Actually starts the coordination - resizes the interactable view to make sure
    /// we have size info, then starts map generation on a background thread
    func start() {
        resizeClosure()
        DispatchQueue.global(qos: .utility).async(execute: chunkCoordinator.startMapGeneration)
    }
    
    /// Creates connections between the objects via delegate pattern
    private func setupInitialDelegates(with view: InteractableViewProtocol) {
        // User interaction delegates first
        view.delegate = renderer
        view.userInteractionDelegate = viewportCoordinator
        renderer.userInteractionDelegate = viewportCoordinator
        
        // Viewport data provider
        chunkCoordinator.viewportDataProvider = viewportCoordinator
        renderer.viewportDataProvider = viewportCoordinator
        
        // Chunk coordinator + viewport coordinator delegates
        chunkCoordinator.chunkCoordinatorDelegate = renderer
        viewportCoordinator.viewportCoordinatorDelegate = renderer
    }
}

/// Just re-renders the renderer, no matter what value updated
extension GameCoordinator: ConfigUpdateDelegate {
    
    func configDidUpdate<T>(from: T?, to: T?) {
        renderer.configDidUpdate()
    }
    
}
