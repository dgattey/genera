// DebugView.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import UI

// MARK: - DebugView

/// Creates a stacked debug view, showing some info on it, kept up to date via implementation of the debug delegate
public class DebugView: NSStackView {
    /// Keeps track of fields for debug types
    private var debugFields: [DebugDataType: NSTextField] = [:]

    /// Updates any field, safely!
    private static func update(_ field: NSTextField?, to value: Any) {
        guard let field = field else {
            assertionFailure("Missing field for \(value)")
            return
        }
        DispatchQueue.main.async {
            field.stringValue = String(describing: value)
        }
    }

    /// Creates a well-configured text field for any debug data
    private static func createTextField() -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: "--")
        field.drawsBackground = true
        field.backgroundColor = .clear
        return field
    }

    /// Add our views when this view moves to a window
    override public func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        LabeledView.addLabel("Debug Info", style: .section, toStack: self)
    }
}

// MARK: - DebugDelegate

extension DebugView: DebugDelegate {
    /// Adds a new field to the view or uses the existing field to update the text
    public func debugDataDidUpdate(_ type: DebugDataType, to value: Any) {
        let actualWork = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let field: NSTextField
            if let savedField = strongSelf.debugFields[type] {
                field = savedField
            } else {
                // Create a new one entirely and add it
                field = DebugView.createTextField()
                strongSelf.debugFields[type] = field
                LabeledView.addView(field, labeledWith: type.rawValue, toStack: strongSelf)
            }
            field.stringValue = String(describing: value)
        }

        // Make sure we're on the main thread to do this
        DispatchQueue.main.async {
            actualWork()
        }
    }
}
