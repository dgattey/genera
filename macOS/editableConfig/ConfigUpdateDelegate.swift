//
//  ConfigUpdateDelegate.swift
//  Genera
//
//  Created by Dylan Gattey on 11/6/20.
//

import Foundation

/// Called in response to configs getting updated
protocol ConfigUpdateDelegate: AnyObject {
    /// Called in response to an update from a value to another value
    func configDidUpdate<T>(from: T?, to: T?)
}
