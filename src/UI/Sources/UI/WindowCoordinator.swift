// WindowCoordinator.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit

/// For presenting info from a window (helper methods)
public enum WindowCoordinator {
    /// Used in prompting for replies
    public typealias PromptResponseClosure = (_ value: String, _ success: Bool) -> Void

    /// Used from anywhere to prompt for a reply
    public static func promptForReply(from window: NSWindow,
                                      withTitle title: String,
                                      details: String,
                                      placeholder: String,
                                      completion: @escaping PromptResponseClosure)
    {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = title
        alert.informativeText = details

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 32))
        textField.bezelStyle = .roundedBezel
        textField.isAutomaticTextCompletionEnabled = true
        textField.isSelectable = true
        textField.maximumNumberOfLines = 6
        textField.lineBreakMode = .byCharWrapping
        textField.usesSingleLineMode = false
        textField.placeholderString = placeholder
        textField.stringValue = ""

        alert.accessoryView = textField
        alert.beginSheetModal(for: window) { response in
            switch response {
            case .alertFirstButtonReturn:
                completion(textField.stringValue, true)
            default:
                completion(textField.stringValue, false)
            }
        }
    }
}
