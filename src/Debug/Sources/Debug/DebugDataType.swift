// DebugDataType.swift
// Copyright (c) 2022 Dylan Gattey

import Foundation

/// Contains all the different types of data we want to debug (raw value is the label for the data)
public enum DebugDataType: String {
    /// Chunk boundary region
    case chunkBounds = "Visible chunk bounds"

    /// Number of generated chunks in memory
    case numChunks = "Generated chunks"

    /// Number of chunks in generation queue and to be generated
    case queuedChunks = "Generation queue"

    /// Position of the user in viewport coordinates
    case userViewport = "User viewport position"

    /// The current window's viewport itself
    case windowViewport = "Window viewport"

    /// Viewport buffer data to pass to GPU
    case viewportBufferData = "Viewport Buffer Data"
}
