//
//  Logger.swift
//  Genera
//
//  Created by Dylan Gattey on 11/1/20.
//

import Foundation

/// Simple logger, with config
enum Logger {

    static let shouldLog = false

    /// Logs a value if logging is on
    static func log(_ value: Any) {
        if (shouldLog) {
            print(String(describing: value))
        }
    }

}
