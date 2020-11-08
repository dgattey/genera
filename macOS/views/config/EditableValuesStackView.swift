//
//  EditableValuesStackView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import Cocoa

/// A stack view containing text fields for certain configurable data
class EditableValuesStackView: NSStackView, NSTextFieldDelegate {
    
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
        addValue(values.scale)
        addValue(values.compression)
        addValue(values.octaves)
        addValue(values.persistence)
        addValue(values.frequency)
    }
    
    /// Makes sure we got a text field, then update
    func controlTextDidChange(_ obj: Notification) {
        guard (obj.object as? NSTextField) != nil else {
            return
        }
        updateDelegate?.configDidUpdate()
    }

}
