//
//  MobileApp.swift
//  Mobile
//
//  Created by tdt on 8/28/24.
//

import SwiftUI

@main
struct MobileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainScreen()
        }
        .commands { commands }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
    }

    @CommandsBuilder
    var commands: some Commands {
        CommandMenu("Muxd") {
            Button("Import Pair Record") {
                let panel = NSOpenPanel()
                panel.title = "Import From Pair Record"
                panel.begin { response in
                    guard response == .OK, let url = panel.url else { return }
                    importPairRecord(from: url)
                }
            }
            Divider()
            Button("Copy Terminal Environment") {
                let string = "export USBMUXD_SOCKET_ADDRESS=UNIX:\(MuxProxy.shared.socketPath.path)"
                NSPasteboard.general.prepareForNewContents()
                NSPasteboard.general.setString(string, forType: .string)
            }
        }
    }
}

func importPairRecord(from url: URL) {
    do {
        try _importPairRecord(from: url)
    } catch {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

private func _importPairRecord(from url: URL) throws {
    let data = try Data(contentsOf: url)
    let pair = try PropertyListDecoder().decode(PairRecord.self, from: data)
    enum ImportError: Error { case deviceNotFound }

    let binaryData = pair.propertyListBinaryData as NSData
    let ret = usbmuxd_save_pair_record_with_device_id(
        pair.udid,
        0,
        binaryData.bytes,
        UInt32(binaryData.length)
    )
    print("[*] usbmuxd_save_pair_record_with_device_id: \(ret)")
    amdManager.sendPairRequest(udid: pair.udid)

    if devManager.devices[pair.udid] == nil {
        let device = Device(
            udid: pair.udid,
            deviceRecord: amdManager.obtainDeviceInfo(udid: pair.udid) ?? .init(),
            pairRecord: pair,
            extra: [:],
            possibleNetworkAddress: []
        )
        devManager.devices[device.udid] = device
    }
}
