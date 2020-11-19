// DebugView.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit
import Combine
import Debug
import Foundation
import UI

// MARK: - DebugView

/// Creates a stacked debug view, showing some info on it, kept up to date via implementation of the debug protocol
class DebugView: NSStackView {
    /// Creates a well-configured text field for any debug data
    private static func createTextField() -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: "--")
        field.drawsBackground = true
        field.backgroundColor = .clear
        return field
    }

    /// Keeps track of fields for debug types
    private var debugFields: [DebugDataType: NSTextField] = [:]

    /// These are the list of subjects that another object can use to send debug
    /// data - make sure to pick the right one for your use
    private var subjects: [DebugDataType: PassthroughSubject<Any, Never>] = [:]

    /// Collects the list of sinks to retain subscribers on added subjects
    private var sinks: [DebugDataType: AnyCancellable] = [:]

    /// Grabs existing or makes a field for a given type
    private func field(for type: DebugDataType) -> NSTextField {
        if let savedField = debugFields[type] {
            return savedField
        } else {
            // Create a new one entirely and add it
            let field = DebugView.createTextField()
            debugFields[type] = field
            LabeledView.addView(field, labeledWith: type.rawValue, toStack: self)
            return field
        }
    }

    /// Add our views when this view moves to a window
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        LabeledView.addLabel("Debug Info", style: .section, toStack: self)
    }
}

// MARK: - DebugProtocol

extension DebugView: DebugProtocol {
    func subject(for type: DebugDataType) -> PassthroughSubject<Any, Never> {
        if let savedSubject = subjects[type] {
            return savedSubject
        }

        // Create a subject and sink to return
        let subject = PassthroughSubject<Any, Never>()
        sinks[type] = subject.receive(on: DispatchQueue.main).sink { value in
            self.field(for: type).stringValue = String(describing: value)
        }
        subjects[type] = subject
        return subject
    }
}
