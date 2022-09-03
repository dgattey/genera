// Logger.swift
// Copyright (c) 2022 Dylan Gattey

import Foundation

/// Simple logger, with config
public enum Logger {
    static let shouldLog = true

    /// Logs a value if logging is on
    public static func log(_ value: Any) {
        if shouldLog {
            print(String(describing: value))
        }
    }
}
