//
//  GameCoordinator.swift
//  Genera
//
//  Created by Dylan Gattey on 10/30/20.
//

import MetalKit

/// Coordinates the game of a certain type of data, created from a Metal view and an optional debug delegate
class GameCoordinator<DataProvider: ChunkDataProvider> {
    
    // MARK: variables
    
    /// Provides all data in the form of vertices and chunks for the other objects
    private let dataProvider: DataProvider
    
    /// Handles user changes to the viewport/translations/visibility of chunks
    private let viewportCoordinator: ViewportCoordinator<DataProvider>
    
    /// Coordinates loading and deleting chunks in response to user moving around. Also contains
    /// actual vertex data for use in rendering
    private let chunkCoordinator: ChunkCoordinator<DataProvider>
    
    /// Renders the content to the screen
    private let renderer: MapRenderer<DataProvider>
    
    // MARK: initialization
    
    /// Initialization will fail if Metal is missing or the renderer isn't
    /// created correctly. Otherwise, sets everything up.
    init?(view: InteractableViewProtocol, debugDelegate: DebugDelegate?) {
        let dataProvider = DataProvider()
        let viewportCoordinator = ViewportCoordinator(initialSize: view.drawableSize, dataProvider: dataProvider)
        let chunkCoordinator = ChunkCoordinator(dataProvider: dataProvider)
        guard let defaultDevice = MTLCreateSystemDefaultDevice(),
              let renderer = MapRenderer(view: view, device: defaultDevice, dataProvider: dataProvider, chunkCoordinator: chunkCoordinator) else {
            assertionFailure("Game coordinator cannot be initialized")
            return nil
        }
        self.renderer = renderer
        self.chunkCoordinator = chunkCoordinator
        self.dataProvider = dataProvider
        self.viewportCoordinator = viewportCoordinator
        
        setupDelegates(with: view, debugDelegate: debugDelegate)
        
        // Resize the renderer's view to make sure we're ready before map generation
        renderer.mtkView(view, drawableSizeWillChange: view.drawableSize)

        // Start map generation to kick off the process!
        DispatchQueue.global(qos: .utility).async(execute: chunkCoordinator.startMapGeneration)
    }
    
    private func setupDelegates(with view: InteractableViewProtocol,
                                debugDelegate: DebugDelegate?) {
        // User interaction delegates first
        view.delegate = renderer
        view.userInteractionDelegate = viewportCoordinator
        renderer.userInteractionDelegate = viewportCoordinator
        
        // Debug delegates
        renderer.debugDelegate = debugDelegate
        chunkCoordinator.debugDelegate = debugDelegate
        viewportCoordinator.debugDelegate = debugDelegate
        
        // Viewport data provider
        chunkCoordinator.viewportDataProvider = viewportCoordinator
        renderer.viewportDataProvider = viewportCoordinator
        
        // Chunk coordinator + viewport coordinator delegates
        chunkCoordinator.chunkCoordinatorDelegate = renderer
        viewportCoordinator.viewportCoordinatorDelegate = renderer
    }
}
