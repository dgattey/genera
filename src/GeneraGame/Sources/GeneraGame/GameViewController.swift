// GameViewController.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import Debug
import Engine

/// All constants for the generic game view controller
enum GameViewControllerConstant {
    /// Minimum window width
    static let minWidth: CGFloat = 250
}

/// The game's view controller - owns the coordinator and kicks off the game itself
public class GameViewController: NSViewController {
    /// Allows for debugging data
    public weak var debugger: DebugProtocol? {
        didSet {
            gridCoordinator?.debugger = debugger
            terrainCoordinator?.debugger = debugger
        }
    }

    /// Returns the current config view if existent from the current coordinator
    public var currentConfigView: NSView? {
        switch gameType {
        case .terrain:
            return terrainCoordinator?.shaderDataProvider
        case .grid:
            return nil
        }
    }

    /// Check `gameType` to verify what type of `GameCoordinator<T>` this should be! Unfortunately doesn't allow for
    /// a more specific use since `GameCoordinator<T>` is a generic with an associated type within it - super difficult
    private var coordinator: Any?

    /// Specializes the coordinator to terrain provider
    private var terrainCoordinator: GameCoordinator<TerrainChunkDataProvider>? {
        coordinator as? GameCoordinator<TerrainChunkDataProvider>
    }

    /// Specializes the coordinator to grid provider
    private var gridCoordinator: GameCoordinator<GridTileChunkDataProvider>? {
        coordinator as? GameCoordinator<GridTileChunkDataProvider>
    }

    /// Controls which coordinator we use!
    private var gameType: GameType = .terrain

    /// Casts the view to a game view if possible
    private var gameView: InteractableMTKView! {
        guard let gameView = view as? InteractableMTKView else {
            assertionFailure("The game view isn't set correctly")
            return nil
        }
        return gameView
    }

    /// Starts the game by creating the coordinator, then kicking it off
    public func reset(to gameType: GameType) {
        gameView.delegate = nil // reset in preparation
        self.gameType = gameType
        switch gameType {
        case .grid:
            guard let coordinator = GameCoordinator<GridTileChunkDataProvider>(view: gameView) else {
                fatalError("No coordinator created")
            }
            coordinator.debugger = debugger
            self.coordinator = coordinator
            coordinator.start()
        case .terrain:
            guard let coordinator = GameCoordinator<TerrainChunkDataProvider>(view: gameView) else {
                fatalError("No coordinator created")
            }
            coordinator.debugger = debugger
            self.coordinator = coordinator
            coordinator.start()
        }
    }

    override public func viewDidLoad() {
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: GameViewControllerConstant.minWidth).isActive = true
    }
}
