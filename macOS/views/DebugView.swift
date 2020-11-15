// DebugView.swift
// Copyright (c) 2020 Dylan Gattey
// Created by Dylan Gattey on 11/1/20.

import AppKit
import Foundation

// MARK: - DebugView

/// Creates a stacked debug view, showing some info on it, kept up to date via implementation of the debug delegate
class DebugView: NSStackView {
    private let visibleChunkBounds = createTextField()
    private let numGeneratedChunks = createTextField()
    private let generationQueue = createTextField()
    private let userPosition = createTextField()
    private let currentViewport = createTextField()

    /// Updates any field, safely!
    private static func update(_ field: NSTextField?, to value: Any) {
        guard let field = field else {
            assertionFailure("Missing field for \(value)")
            return
        }
        DispatchQueue.main.async {
            field.stringValue = String(describing: value)
        }
    }

    /// Creates a well-configured text field for any debug data
    private static func createTextField() -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: "--")
        field.drawsBackground = true
        field.backgroundColor = .clear
        return field
    }

    /// Add our views when this view moves to a window
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        LabeledView.addLabel("Debug Info", style: .section, toStack: self)
        LabeledView.addView(visibleChunkBounds, labeledWith: "Visible chunk bounds", toStack: self)
        LabeledView.addView(numGeneratedChunks, labeledWith: "Generated chunks", toStack: self)
        LabeledView.addView(generationQueue, labeledWith: "Generation queue", toStack: self)
        LabeledView.addView(userPosition, labeledWith: "User viewport position", toStack: self)
        LabeledView.addView(currentViewport, labeledWith: "Window viewport", toStack: self)
    }
}

// MARK: - DebugDelegate

extension DebugView: DebugDelegate {
    func didUpdateChunkBounds(to value: ChunkRegion) {
        DebugView.update(visibleChunkBounds, to: value)
    }

    func didUpdateNumGeneratedChunks(to value: Int) {
        DebugView.update(numGeneratedChunks, to: value)
    }

    func didUpdateGenerationQueue(to value: (needsGeneration: Int, inProgress: Int)) {
        DebugView.update(generationQueue, to: value)
    }

    func didUpdateUserPosition(to value: MTLViewport) {
        DebugView.update(userPosition, to: value)
    }

    func didUpdateCurrentViewport(to value: MTLViewport) {
        DebugView.update(currentViewport, to: value)
    }
}
