//
//  EditableConfigValue.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// A config value, containing the text field used to display the value, plus a default fallback
class EditableConfigValue<T: LosslessStringConvertible> {
    
    // MARK: - EditableConfigValue
    
    /// The text field where the user can edit the value
    let field: NSTextField
    
    /// The label for this value
    let label: String
    
    /// The fallback value
    private let fallback: T
    
    /// Returns the value of the field as a casted optional value or the saved fallback value
    var value: T {
        return T.init(field.stringValue) ?? fallback
    }
    
    /// Saves the field, configures it, and saves fallback and label
    private init(field: NSTextField, fallback: T, label: String) {
        field.placeholderString = String(describing: fallback)
        field.bezelStyle = .roundedBezel
        self.field = field
        self.fallback = fallback
        self.label = label
    }
    
    /// For use in creating an .wholeNumber field
    convenience init(fallback: T, label: String) where T: BinaryInteger {
        let field = EditableConfigValueField(fallback)
        self.init(field: field, fallback: fallback, label: label)
    }
    
    /// For use in creating a .decimalNumber field
    convenience init(fallback: T, label: String) where T: BinaryFloatingPoint {
        let field = EditableConfigValueField(fallback)
        self.init(field: field, fallback: fallback, label: label)
    }
    
    /// For use in creating a .string field
    convenience init(fallback: T, label: String) where T: StringProtocol {
        let field = EditableConfigValueField(fallback)
        self.init(field: field, fallback: fallback, label: label)
    }
}
