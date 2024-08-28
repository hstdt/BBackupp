//
//  DeviceView.swift
//  BBackupp
//
//  Created by 秋星桥 on 2024/1/10.
//

import SwiftUI

struct DeviceView: View {
    let udid: Device.ID

    @StateObject var vm = devManager
#if !Mobile
    @StateObject var backupManager = bakManager
#endif

    var device: Device { vm.devices[udid, default: .init()] }

    @State var openExportPairRecordPanel = false
    @State var openWirelessSetupPanel = false
    @State var openBackupEncryptionSetupPanel = false

    @State var openSymbolPickerPanel = false
    @State var openTrashDeviceAlert = false

    @State var openOneTimeBackup = false
#if !Mobile
    @State var openBackupTask: BackupTask? = nil

    var runningBackupTask: BackupTask? {
        backupManager.tasks
            .filter(\.executing)
            .filter { $0.config.device.udid == udid }
            .first
    }
#endif

    var body: some View {
        Group {
            if vm.devices[udid] == nil {
                Text("Device Removed")
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                content
                    .onAppear { devManager.refreshDevice(udid) }
                    .toolbar { toolbar }
                    .navigationTitle("\(device.deviceName)")
            }
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            header.padding(16)
            Divider()
#if Mobile
            InstalledAppListView(udid: udid)
                .frame(maxHeight: .infinity)
#else
            BackupListView(udid: udid)
#endif
        }
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                openSymbolPickerPanel = true
            } label: {
                Image(systemName: device.deviceSystemIcon)
            }
            .help("Symbol Picker")
            .sheet(isPresented: $openSymbolPickerPanel) {
                SymbolPickerPanelView { symbol in
                    vm.devices[udid]?.extra[.preferredIcon] = symbol
                }
            }
        }

        ToolbarItem {
            Button {} label: { DeviceReachableLabel(udid: udid) }
                .disabled(true)
        }

        ToolbarItem {
            Button {} label: { Image(systemName: "circle.fill").opacity(0) }
                .disabled(true)
        }

        ToolbarItem {
            Button {
                openExportPairRecordPanel = true
            } label: {
                Label("Export Pair Record", systemImage: "key.viewfinder")
            }
            .help("Export Pair Record")
            .sheet(isPresented: $openExportPairRecordPanel) {
                ExportPairRecordSheetView(udid: device.udid)
            }
        }

        ToolbarItem {
            Button {
                openWirelessSetupPanel = true
            } label: {
                Label("Wireless Connection", systemImage: "wifi")
            }
            .help("Wireless Connection")
            .sheet(isPresented: $openWirelessSetupPanel) {
                WirelessConfigurationSheetView(udid: device.udid)
            }
        }

#if !Mobile
        ToolbarItem {
            Button {
                openBackupEncryptionSetupPanel = true
            } label: {
                Label("Backup Encryption", systemImage: "lock.doc")
            }
            .help("Backup Encryption")
            .sheet(isPresented: $openBackupEncryptionSetupPanel) {
                BackupEncryptionConfigurationSheetView(udid: device.udid)
            }
        }
#endif

        ToolbarItem {
            Button {
                openTrashDeviceAlert = true
            } label: {
                Label("Unregister", systemImage: "trash")
            }
            .help("Unregister")
            .alert(isPresented: $openTrashDeviceAlert) {
                Alert(
                    title: Text("Are you sure you want to unregister this device?"),
                    primaryButton: .destructive(Text("Unregister")) { vm.devices[udid] = nil },
                    secondaryButton: .cancel()
                )
            }
        }

        ToolbarItem {
            Button {} label: { Image(systemName: "circle.fill").opacity(0) }
                .disabled(true)
        }

#if !Mobile
        ToolbarItem {
            Button {
                if runningBackupTask != nil {
                    openBackupTask = runningBackupTask
                } else {
                    openOneTimeBackup = true
                }
            } label: {
                if runningBackupTask != nil {
                    Label("Backup", systemImage: "figure.run")
                        .foregroundStyle(.green)
                } else {
                    Label("Backup", systemImage: "paperplane")
                        .foregroundStyle(.accent)
                }
            }
            .help("Backup")
            .sheet(isPresented: $openOneTimeBackup) {
                OneTimeBackupPanelView(udid: udid)
            }
            .sheet(item: $openBackupTask) { task in
                BackupTaskView(task: task)
            }
        }
#endif
    }

    var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading) {
                DeviceValuePair(title: "Model", value: device.deviceRecord.productType)
                DeviceValuePair(title: "System", value: [
                    device.deviceRecord.productName, device.deviceRecord.productVersion,
                ].compactMap { $0 }.joined(separator: " "))
                DeviceValuePair(title: "IMEI 1", value: device.deviceRecord.internationalMobileEquipmentIdentity)
                DeviceValuePair(title: "IMEI 2", value: device.deviceRecord.internationalMobileEquipmentIdentity2)
            }
            VStack(alignment: .leading) {
                DeviceValuePair(title: "Serial Number", value: device.deviceRecord.serialNumber)
                DeviceValuePair(title: "UDID", value: device.udid)
                DeviceValuePair(title: "ECID", value: device.deviceRecord.uniqueChipID)
                DeviceValuePair(title: "Last Seen", value: device.deviceRecordLastUpdate)
            }
        }
        .font(.footnote)
        .textSelection(.enabled)
    }
}

private struct DeviceValuePair: View {
    let title: String
    let value: Any?

    let notAvail = "Not Available"
    var str: String {
        guard let value else { return notAvail }
        if let date = value as? Date {
            return date.formatted(date: .abbreviated, time: .standard)
        }
        let str = String(describing: value)
        guard !str.isEmpty else { return notAvail }
        return str
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(title).frame(width: 72, alignment: .leading)
            Text(":")
            Text(str).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
