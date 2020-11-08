//
//  EditableValuesStackView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// A stack view containing text fields for certain configurable data
class EditableValuesStackView: NSStackView, NSTextFieldDelegate {
    
    /// For use in checking values for int strings
    private static let integerSet = NSCharacterSet(charactersIn: "-1234567890").inverted
    
    /// For use in checking values for float strings
    private static let floatSet = NSCharacterSet(charactersIn: "-1234567890.").inverted
    
    /// The title of this stack
    private let title: String
    
    /// Called when we update a value
    weak var updateDelegate: TerrainConfigUpdateDelegate?
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        LabeledView.addLabel(title, style: .section, toStack: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Add our views!
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
    }
    
    /// Adds the text field from the value to this stack view
    func addValue<T>(_ value: EditableConfigValue<T>) {
        value.field.delegate = self
        LabeledView.addView(value.field, labeledWith: value.label, toStack: self)
    }
    
    /// Convenience function for adding editable FBM data to this view
    func addFBMValues(_ values: EditableFBMConfigValues) {
        addValue(values.octaves)
        addValue(values.persistence)
        addValue(values.scale)
        addValue(values.compression)
    }
    
    /// Makes sure we got a text field, then update
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? EditableConfigValueField else {
            return
        }
        defer {
            updateDelegate?.configDidUpdate()
        }
        
        switch textField.valueType {
        case .decimalNumber:
            // Restrict it to only one . and integers
            let chars = textField.stringValue.components(
                separatedBy: EditableValuesStackView.floatSet)
            var stringValue = chars.joined()
            
            // Remove extra . if we have them
            let chunks = stringValue.components(separatedBy: ".")
            switch chunks.count {
            case 0:
                stringValue = ""
            case 1:
                stringValue = "\(chunks[0])"
            default:
                stringValue = "\(chunks[0]).\(chunks[1])"
            }
            
            textField.stringValue = stringValue
        case .wholeNumber:
            // Restrict it to whole values
            let chars = textField.stringValue.components(
                separatedBy: EditableValuesStackView.integerSet)
            textField.stringValue = chars.joined()
        case .string:
            // This is anything you want it to be
            break
        }
        
    }

}
