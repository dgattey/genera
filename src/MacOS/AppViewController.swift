// AppViewController.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit

/// A regular split view, with the addition of a titlebar view
class AppViewController: NSSplitViewController {
    // MARK: - variables

    /// The titlebar view that positions itself at the top of the view
    private let titlebarView = HideableTitlebarView()

    /// Keeps track of if the sidebar is collapsed and reacts to that
    private var collapseObserver: NSKeyValueObservation?

    /// Adds the titlebar view, and sets up the observer
    override func viewWillAppear() {
        super.viewWillAppear()
        view.addSubview(titlebarView)

        // Observe the sidebar's collapse state so we can update the state of the title bar
        let sidebarItem = splitViewItems[0]
        collapseObserver = sidebarItem.observe(\.isCollapsed, options: [.initial, .new]) { [weak self] sidebarItem, _ in
            self?.titlebarView.isSidebarCollapsed.send(sidebarItem.isCollapsed)
        }
    }
}
