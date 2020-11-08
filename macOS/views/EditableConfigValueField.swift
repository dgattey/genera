//
//  EditableConfigValueField.swift
//  Genera
//
//  Created by Dylan Gattey on 11/7/20.
//

import AppKit

/// A field with associated value type for use later in delegate methods
class EditableConfigValueField: NSTextField {
    
    // MARK: - constants
    
    /// For use in checking values for int strings
    private static let integerSet = NSCharacterSet(charactersIn: "-1234567890").inverted
    
    /// For use in checking values for float strings
    private static let floatSet = NSCharacterSet(charactersIn: "-1234567890.").inverted
    
    // MARK: - types
    
    /// The class of value we're using, based on protocols!
    enum ValueType {
        case decimalNumber
        case wholeNumber
        case string
    }
    
    // MARK: - variables
    
    /// For using arrow keys/mouse on the numeric fields
    let stepper: NSStepper?
    
    /// What type of field this is
    let valueType: ValueType
    
    /// The update delegate to call when we change data
    weak var updateDelegate: TerrainConfigUpdateDelegate?
    
    /// Used if we need a float formatter
    private lazy var floatFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.allowsFloats = true
        formatter.roundingMode = .down
        return formatter
    }()
    
    // MARK: - initialization
    
    init<T: BinaryFloatingPoint>(_ value: T) {
        self.valueType = .decimalNumber
        let stepper = NSStepper()
        stepper.autorepeat = true
        stepper.increment = 0.1
        stepper.minValue = -Double.infinity
        stepper.maxValue = Double.infinity
        stepper.floatValue = Float(value)
        self.stepper = stepper
        super.init(frame: .zero)
        
        self.formatter = floatFormatter
        self.stringValue = String(describing: value)
    }
    
    init<T: BinaryInteger>(_ value: T) {
        self.valueType = .wholeNumber
        let stepper = NSStepper()
        stepper.autorepeat = true
        stepper.increment = 1.0
        stepper.minValue = -Double.infinity
        stepper.maxValue = Double.infinity
        stepper.integerValue = Int(value)
        self.stepper = stepper
        super.init(frame: .zero)
        
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        self.formatter = formatter
        self.stringValue = String(describing: value)
    }
    
    init<T: StringProtocol>(_ value: T) {
        self.valueType = .string
        self.stepper = nil
        super.init(frame: .zero)
        self.stringValue = String(describing: value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    /// Called from the NSStepper to update the text field
    @objc func updateValue() {
        guard let stepper = stepper else {
            assertionFailure("Wrong updateValue called")
            return
        }
        defer {
            updateDelegate?.configDidUpdate()
        }
        switch valueType {
        case .decimalNumber:
            formatter = floatFormatter // in case it's not currently set
            floatValue = stepper.floatValue
        case .wholeNumber:
            integerValue = stepper.integerValue
        default:
            break
        }
    }
}

// MARK: - NSTextFieldDelegate

extension EditableConfigValueField: NSTextFieldDelegate {
    
    /// Changes the text as needed based on the type, and updates our delegate
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? EditableConfigValueField else {
            return
        }
        defer {
            updateDelegate?.configDidUpdate()
        }
        
        switch textField.valueType {
        
        // For a decimal, we grab the unformatted and formatted values, disabling the formatter if we have
        // trailing zeros or trailing . because with either, the formatter would just format them right off.
        // Numbers like 0. and 0.000 are still valid, as are 328.000 - you're "on your way" to typing something.
        // Easier to swap in/out the formatter than deal with it through delegate methods/subclassing
        case .decimalNumber:
            defer {
                // Make sure the update the stepper at the esssssssssssssssssnd
                stepper?.floatValue = textField.floatValue
            }
            textField.formatter = nil
            let unformattedValue = textField.stringValue
            let formattedValue = floatFormatter.number(from: textField.stringValue)
            let hasPointSuffix = unformattedValue.hasSuffix(".")
            let hasZeroSuffix = unformattedValue.hasSuffix("0")
            let hasMinusPrefix = unformattedValue.hasPrefix("-")
            let hasSingleMinus = unformattedValue.unicodeScalars.filter({ $0 == "-" }).count < 2
            
            // If there's a decimal, our formatter would rewrite to something, so leave it off for now
            if hasPointSuffix || hasZeroSuffix {
                if formattedValue == nil {
                    // Make sure to add the leading zero so it doesn't pop in later
                    textField.stringValue = "0."
                }
            } else if hasMinusPrefix && !hasSingleMinus && formattedValue == nil {
                // Nicely pad & format the negative version
                textField.stringValue = "-0."
            } else {
                textField.formatter = floatFormatter
            }
            
        // Update the stepper!
        case .wholeNumber:
            stepper?.integerValue = textField.integerValue
            
        // No changes needed
        case .string:
            break
        }
        
    }
    
}
