// DebugDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation
import MetalKit

/// Anything that shows debug data implements this
public protocol DebugDelegate: NSObject {
    /// Called when anything updates - based on type we set the right value
    func debugDataDidUpdate(_ type: DebugDataType, to value: Any) -> Void
}
