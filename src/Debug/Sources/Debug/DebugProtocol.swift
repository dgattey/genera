// DebugProtocol.swift
// Copyright (c) 2020 Dylan Gattey

import Combine

/// Anything showing debug data must conform
public protocol DebugProtocol: AnyObject {
    /// Allows sending data to a subscriber for a particular debug data type
    func subject(for type: DebugDataType) -> PassthroughSubject<Any, Never>
}
