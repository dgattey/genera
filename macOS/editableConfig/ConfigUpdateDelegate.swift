// ConfigUpdateDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Called in response to configs getting updated
protocol ConfigUpdateDelegate: AnyObject {
    /// Called in response to an update from a value to another value
    func configDidUpdate<T>(from: T?, to: T?)
}
