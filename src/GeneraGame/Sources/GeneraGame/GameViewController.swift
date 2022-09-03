// GameViewController.swift
// Copyright (c) 2022 Dylan Gattey

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
            coordinator?.debugger = debugger
        }
    }

    /// Returns the current config view if existent from the current coordinator
    public var currentConfigView: NSView? {
        return coordinator?.shaderDataProvider
    }

    /// Specializes the coordinator to terrain provider
    private var coordinator: GameCoordinator<TerrainChunkDataProvider>?

    /// Casts the view to a game view if possible
    private var gameView: InteractableMTKView! {
        guard let gameView = view as? InteractableMTKView else {
            assertionFailure("The game view isn't set correctly")
            return nil
        }
        return gameView
    }

    /// Starts the game by creating the coordinator, then kicking it off
    public func reset() {
        gameView.delegate = nil // reset in preparation
        guard let coordinator = GameCoordinator<TerrainChunkDataProvider>(view: gameView) else {
            fatalError("No coordinator created")
        }
        coordinator.debugger = debugger
        self.coordinator = coordinator
        coordinator.start()
    }

    override public func viewDidLoad() {
        view.widthAnchor.constraint(greaterThanOrEqualToConstant: GameViewControllerConstant.minWidth).isActive = true
    }
}
