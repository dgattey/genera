//
//  LabeledView.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// Contains a bunch of static funcs to create views with associated labels in stacks
enum LabeledView {
    
    // MARK: - types
    
    /// Styles of headers (labels) we can create
    enum HeaderStyle {
        
        /// Represents the bolded toolbar label for the whole app
        case appBold
        
        /// Represents a full section with a big header
        case section
        
        /// Represents a field inside a section with smaller header
        case field
        
        /// The font for this type of header (sized and weighted appropriately)
        var font: NSFont {
            switch self {
            case .appBold:
                return NSFont.systemFont(ofSize: 100, weight: .heavy)
            case .section:
                return NSFont.systemFont(ofSize: 30, weight: .heavy)
            case .field:
                return NSFont.systemFont(ofSize: 14, weight: .medium)
            }
        }
        
        /// The spacing that appears around this header in a stack (total: half above, half below)
        var spacing: CGFloat {
            switch self {
            case .appBold:
                return 0
            case .section:
                return 32
            case .field:
                return 16
            }
        }
    }
    
    // MARK: - API
    
    /// Creates a label text field with string and font size
    static func createLabel(from text: String, style: HeaderStyle) -> NSTextField {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.font,
            .foregroundColor: NSColor.labelColor,
        ]
        let string = NSAttributedString(string: text, attributes: attributes)
        let field = NSTextField(labelWithAttributedString: string)
        field.drawsBackground = false
        field.allowsEditingTextAttributes = true
        field.isSelectable = true
        return field
    }
    
    /// Adds a single label to a the stack view
    static func addLabel(_ text: String,
                         style: HeaderStyle = .field,
                         toStack stack: NSStackView) {
        let label = createLabel(from: text, style: style)
        add([label], withPaddingFrom: style, toStack: stack)
    }
    
    /// Adds a view with a label above to the stack view
    static func addView(_ view: NSView,
                        labeledWith text: String,
                        style: HeaderStyle = .field,
                        toStack stack: NSStackView) {
        let label = createLabel(from: text, style: style)
        add([label, view], withPaddingFrom: style, toStack: stack)
    }
    
    // MARK: - private helpers
    
    /// Adds half of the spacing in the header style to the last view in the stack if it exists
    private static func add(_ views: [NSView],
                            withPaddingFrom style: HeaderStyle,
                            toStack stack: NSStackView) {
        // If there was a view, add half this item's spacing
        if let lastView = stack.views.last {
            stack.setCustomSpacing(style.spacing / 2 + stack.customSpacing(after: lastView), after: lastView)
        }
        for view in views {
            stack.addView(view, in: .bottom)
        }
        guard let lastView = views.last else {
            assertionFailure("Not enough views to pad")
            return
        }
        stack.setCustomSpacing(style.spacing / 2, after: lastView)
    }
    
}
