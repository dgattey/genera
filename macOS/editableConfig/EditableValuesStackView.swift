//
//  EditableValuesStackView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// A stack view containing text fields for certain configurable data
class EditableValuesStackView: NSStackView {

    // MARK: - initialization
    
    init(title: String) {
        super.init(frame: .zero)
        LabeledView.addLabel(title, style: .section, toStack: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
    }
    
    // MARK: - API
    
    /// Adds the text field and optional stepper from the value to this stack view
    func addValue<T>(_ value: EditableConfigValue<T>) {
        value.field.delegate = value
        let stack = NSStackView()
        stack.distribution = .fill
        LabeledView.addView(value.field, labeledWith: value.label, toStack: stack)
        
        // Make sure to setup the stepper and its action properly
        if let stepper = value.stepper {
            stepper.target = value
            stepper.action = #selector(EditableConfigValue<T>.updateValue)
            stack.addView(stepper, in: .trailing)
        }
        addView(stack, in: .bottom)
    }
    
}
