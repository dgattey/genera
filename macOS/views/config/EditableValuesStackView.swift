//
//  EditableValuesStackView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// A stack view containing text fields for certain configurable data
class EditableValuesStackView: NSStackView {
    
    // MARK: - variables
    
    /// The title of this stack
    private let title: String
    
    /// Called when we update the delegate - and all nested fields need their values updated too
    weak var updateDelegate: TerrainConfigUpdateDelegate? {
        didSet {
            setNestedDelegates(in: self)
        }
    }
    
    // MARK: - initialization
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        LabeledView.addLabel(title, style: .section, toStack: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        value.field.delegate = value.field
        value.field.updateDelegate = updateDelegate
        let stack = NSStackView()
        LabeledView.addView(value.field, labeledWith: value.label, toStack: stack)
        
        // Make sure to setup the action properly
        if let stepper = value.field.stepper {
            stepper.target = value.field
            stepper.action = #selector(EditableConfigValueField.updateValue)
            stack.addView(stepper, in: .trailing)
        }
        addView(stack, in: .bottom)
    }
    
    /// Convenience function for adding editable FBM data to this view
    func addFBMValues(_ values: EditableFBMConfigValues) {
        addValue(values.octaves)
        addValue(values.persistence)
        addValue(values.scale)
        addValue(values.compression)
    }
    
    // MARK: - private help
    
    /// Used in updating nested delegates
    private func setNestedDelegates(in stack: NSStackView) {
        for view in stack.views {
            if let field = view as? EditableConfigValueField {
                field.updateDelegate = updateDelegate
            }
            if let substack = view as? NSStackView {
                setNestedDelegates(in: substack)
            }
        }
    }
    
}
