// AppDelegate.swift
// Copyright (c) 2020 Dylan Gattey

import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}
