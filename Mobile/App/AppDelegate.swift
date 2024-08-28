//
//  AppDelegate.swift
//  BBackupp
//
//  Created by tdt on 8/28/24.
//

import AppKit
import IOKit
import IOKit.pwr_mgt
@_exported import AppleMobileDeviceLibrary

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    NSLog(items.map { "\($0)" }.joined(separator: separator) + terminator)
}

let documentDir: URL = FileManager.default.urls(
    for: .documentDirectory,
    in: .userDomainMask
)
.first!
.appendingPathComponent(Constants.appName)
let tempDir: URL = .init(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent(Constants.appName)
let logDir = documentDir.appendingPathComponent("Logs")

class AppDelegate: NSObject {
    lazy var statusItem: NSStatusItem = {
        let robotImage = NSImage(named: "Robot")!
        robotImage.size = .init(width: 18, height: 18)
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = robotImage
        item.button?.target = self
        item.button?.action = #selector(activateStatusMenu(_:))
        return item
    }()

    override private init() {
        super.init()
    }

    func applicationDidFinishLaunching(_: Notification) {
    }

    @objc
    func activateStatusMenu(_: Any) {
        // popover.showPopover(statusItem: statusItem)
    }

    var assertionID: IOPMAssertionID = 0
}

extension AppDelegate: NSApplicationDelegate {
    func applicationShouldTerminate(_: NSApplication) -> NSApplication.TerminateReply {
        return .terminateNow
    }

    func applicationWillTerminate(_: Notification) {

    }
}
