//
//  EditableConfigValue.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Cocoa

/// A config value, containing the text field used to display the value, plus a default fallback
class EditableConfigValue<T: LosslessStringConvertible>: NSCoding {
    
    /// The text field where the user can edit the value
    let field: NSTextField
    
    /// The label for this value
    let label: String
    
    /// The fallback value
    private let fallback: T
    
    /// Saves the fallback value for use later
    init(fallback: T, label: String) {
        self.field = NSTextField(string: String(describing: fallback))
        self.fallback = fallback
        self.label = label
    }
    
    /// Returns the value of the field as a casted optional value or the saved fallback value
    var value: T {
        return T.init(field.stringValue) ?? fallback
    }
    
    // MARK: - NSCoding
    
    /// For encoding + decoding
    private enum Keys: String {
        case fallback
        case label
    }
    
    /// Encodes fallback and label
    func encode(with coder: NSCoder) {
        coder.encode(fallback, forKey: Keys.fallback.rawValue)
        coder.encode(label, forKey: Keys.label.rawValue)
    }
    
    /// Decodes fallback and label
    required convenience init?(coder: NSCoder) {
        guard let fallback = coder.decodeObject(forKey: Keys.fallback.rawValue) as? T,
              let label = coder.decodeObject(forKey: Keys.label.rawValue) as? String else {
            return nil
        }
        self.init(fallback: fallback, label: label)
    }
}
