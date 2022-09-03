// AppDelegate.swift
// Copyright (c) 2022 Dylan Gattey

import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}
