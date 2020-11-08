//
//  EditableConfigValueField.swift
//  Genera
//
//  Created by Dylan Gattey on 11/7/20.
//

import AppKit

/// A field with associated value type for use later in delegate methods
class EditableConfigValueField: NSTextField {
    
    /// The class of value we're using, based on protocols!
    enum ValueType {
        case decimalNumber
        case wholeNumber
        case string
    }
    
    /// What type of field this is
    let valueType: ValueType
    
    init<T: BinaryFloatingPoint>(_ value: T) {
        self.valueType = .decimalNumber
        super.init(frame: .zero)
        self.stringValue = String(describing: value)
    }
    
    init<T: BinaryInteger>(_ value: T) {
        self.valueType = .wholeNumber
        super.init(frame: .zero)
        self.stringValue = String(describing: value)
    }
    
    init<T: StringProtocol>(_ value: T) {
        self.valueType = .string
        super.init(frame: .zero)
        self.stringValue = String(describing: value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
