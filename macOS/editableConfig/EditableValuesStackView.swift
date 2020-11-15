// EditableValuesStackView.swift
// Copyright (c) 2020 Dylan Gattey
// Created by Dylan Gattey on 11/5/20.

import AppKit

/// A stack view containing text fields for certain configurable data
class EditableValuesStackView: NSStackView {
    // MARK: - constants

    private static let minFieldWidth: CGFloat = 80

    // MARK: - initialization

    init(title: String) {
        super.init(frame: .zero)
        LabeledView.addLabel(title, style: .section, toStack: self)
    }

    required init?(coder _: NSCoder) {
        super.init(frame: .zero)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        orientation = .vertical
        alignment = .leading
        distribution = .fill
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
    }

    // MARK: - API

    /// Adds the text field and optional stepper from the value to this stack view
    func addValue<T>(_ value: EditableConfigValue<T>) {
        value.field.delegate = value
        value.field.setContentHuggingPriority(.required, for: .horizontal)
        value.field.widthAnchor.constraint(greaterThanOrEqualToConstant: EditableValuesStackView.minFieldWidth).isActive = true
        let stack = NSStackView()
        stack.distribution = .fill
        stack.setContentHuggingPriority(.required, for: .horizontal)
        LabeledView.addView(value.field, labeledWith: value.label, toStack: stack)

        // Make sure to setup the stepper and its action properly
        if let stepper = value.stepper {
            stepper.setContentHuggingPriority(.required, for: .horizontal)
            stepper.target = value
            stepper.action = #selector(EditableConfigValue<T>.updateValue)
            stack.addView(stepper, in: .trailing)
        }
        addView(stack, in: .bottom)
    }
}
