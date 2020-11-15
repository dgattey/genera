// Logger.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// Simple logger, with config
enum Logger {
    static let shouldLog = true

    /// Logs a value if logging is on
    static func log(_ value: Any) {
        if shouldLog {
            print(String(describing: value))
        }
    }
}
