// EditableConfigValue.swift
// Copyright (c) 2022 Dylan Gattey

import AppKit
import Combine
import EngineCore

/// So we can use constants in this file
private enum EditableConfigValueConstant {
    /// For use in checking values for int strings
    static let integerSet = NSCharacterSet(charactersIn: "-1234567890").inverted

    /// For use in checking values for float strings
    static let floatSet = NSCharacterSet(charactersIn: "-1234567890.").inverted
}

/// A config value, containing the text field used to display the value, plus a default fallback
public class EditableConfigValue<T: LosslessStringConvertible>: NSObject, NSTextFieldDelegate {
    // MARK: - types

    /// The class of value we're using, based on protocols!
    private enum ValueType {
        case decimalNumber
        case wholeNumber
        case string
    }

    // MARK: - variables

    /// The text field where the user can edit the value
    let field: NSTextField

    /// For using arrow keys/mouse on the numeric fields
    let stepper: NSStepper?

    /// The label for this value
    let label: String

    /// The fallback value
    private let fallback: T

    /// What type of field this is
    private let valueType: ValueType

    /// Used if we need a float formatter
    private lazy var floatFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.allowsFloats = true
        formatter.roundingMode = .down
        return formatter
    }()

    /// Publishes the actions this value emits
    private let publisher = PassthroughSubject<EditableConfigAction, Never>()

    /// Returns the value of the field as a casted optional value or the saved fallback value
    public var value: T {
        T(field.stringValue) ?? fallback
    }

    // MARK: - initialization

    /// Saves the field, configures it, and saves fallback and label
    private init(valueType: ValueType,
                 fallback: T,
                 label: String,
                 stepper: NSStepper? = nil)
    {
        let field = NSTextField()
        field.stringValue = String(describing: fallback)
        field.placeholderString = String(describing: fallback)
        field.bezelStyle = .roundedBezel
        self.valueType = valueType
        self.field = field
        self.stepper = stepper
        self.fallback = fallback
        self.label = label
        super.init()

        // Add the right formatter
        switch valueType {
        case .decimalNumber:
            field.formatter = floatFormatter
        case .wholeNumber:
            let formatter = NumberFormatter()
            formatter.allowsFloats = false
            field.formatter = formatter
        case .string:
            break
        }
    }

    /// For use in creating a .wholeNumber field
    public convenience init(fallback: T, label: String) where T: BinaryInteger {
        let stepper = NSStepper()
        stepper.autorepeat = true
        stepper.increment = 1.0
        stepper.minValue = -Double.infinity
        stepper.maxValue = Double.infinity
        stepper.integerValue = Int(fallback)
        self.init(valueType: .wholeNumber, fallback: fallback, label: label, stepper: stepper)
    }

    /// For use in creating an .decimalNumber field
    public convenience init(fallback: T, label: String) where T: BinaryFloatingPoint {
        let stepper = NSStepper()
        stepper.autorepeat = true
        stepper.increment = 0.1
        stepper.minValue = -Double.infinity
        stepper.maxValue = Double.infinity
        stepper.floatValue = Float(fallback)
        self.init(valueType: .decimalNumber, fallback: fallback, label: label, stepper: stepper)
    }

    /// For use in creating a .string field
    public convenience init(fallback: T, label: String) where T: StringProtocol {
        self.init(valueType: .string, fallback: fallback, label: label)
    }

    // MARK: - API

    /// Updates the current value to a given value in both the stepper and field itself, and updates the delegate
    public func changeValue(to value: Any) {
        switch valueType {
        case .decimalNumber:
            field.formatter = floatFormatter // in case it's not currently set
            field.stringValue = String(describing: value)
            stepper?.floatValue = field.floatValue
            publisher.send(.changeValue)
        case .wholeNumber:
            field.stringValue = String(describing: value)
            stepper?.intValue = field.intValue
            publisher.send(.changeValue)
        case .string:
            field.stringValue = String(describing: value)
            stepper?.stringValue = field.stringValue
            publisher.send(.changeValue)
        }
    }

    /// Called from the NSStepper to update the text field
    @objc func updateValue() {
        guard let stepper = stepper else {
            assertionFailure("Wrong updateValue called")
            return
        }
        switch valueType {
        case .decimalNumber:
            field.formatter = floatFormatter // in case it's not currently set
            field.floatValue = stepper.floatValue
            publisher.send(.changeValue)
        case .wholeNumber:
            field.integerValue = stepper.integerValue
            publisher.send(.changeValue)
        case .string:
            assertionFailure("Strings should not have steppers")
        }
    }

    // MARK: - NSTextFieldDelegate

    /// Changes the text as needed based on the type, and updates our delegate
    public func controlTextDidChange(_ obj: Notification) {
        guard obj.object as? NSTextField != nil else {
            return
        }

        switch valueType {
        // For a decimal, we grab the unformatted and formatted values, disabling the formatter if we have
        // trailing zeros or trailing . because with either, the formatter would just format them right off.
        // Numbers like 0. and 0.000 are still valid, as are 328.000 - you're "on your way" to typing something.
        // Easier to swap in/out the formatter than deal with it through delegate methods/subclassing
        case .decimalNumber:
            defer {
                // Make sure the update the stepper & update the delegate
                stepper?.floatValue = field.floatValue
                publisher.send(.changeValue)
            }
            field.formatter = nil
            let unformattedValue = field.stringValue
            let formattedValue = floatFormatter.number(from: field.stringValue)
            let hasPointSuffix = unformattedValue.hasSuffix(".")
            let hasZeroSuffix = unformattedValue.hasSuffix("0")
            let hasMinusPrefix = unformattedValue.hasPrefix("-")
            let hasSingleMinus = unformattedValue.unicodeScalars.filter { $0 == "-" }.count < 2

            // If there's a decimal, our formatter would rewrite to something, so leave it off for now
            if hasMinusPrefix && hasSingleMinus && formattedValue == nil {
                // Nicely pad & format the negative version
                field.stringValue = "-0."
            } else if hasPointSuffix || hasZeroSuffix {
                if formattedValue == nil {
                    // Make sure to add the leading zero so it doesn't pop in later
                    field.stringValue = "0."
                }
            } else {
                field.formatter = floatFormatter
            }

        // Update the stepper and delegate
        case .wholeNumber:
            stepper?.integerValue = field.integerValue
            publisher.send(.changeValue)

        // No changes needed, but update the delegate
        case .string:
            publisher.send(.changeValue)
        }
    }
}

// MARK: - Publisher

extension EditableConfigValue: Publisher {
    public typealias Output = EditableConfigAction
    public typealias Failure = Never

    /// Connect the built-in publisher to the subscriber sent
    public func receive<S>(subscriber: S)
        where S: Subscriber,
        EditableConfigValue.Failure == S.Failure,
        EditableConfigValue.Output == S.Input
    {
        publisher.subscribe(subscriber)
    }
}
