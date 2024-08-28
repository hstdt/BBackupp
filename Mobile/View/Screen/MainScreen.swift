//
//  MainScreen.swift
//
//
//  Created by tdt on 8/28/24.
//

import SwiftUI

private extension View {
    @ViewBuilder
    func limitMinSize() -> some View {
        frame(minWidth: 550, minHeight: 350)
    }
}

struct MainScreen: View {
    @AppStorage("AgreedToLicense") var agreedToLicense = false

    var body: some View {
        NavigationSplitView {
            sidebar.navigationSplitViewColumnWidth(min: 150, ideal: 150, max: 300)
        } detail: {
            WelcomeView().limitMinSize()
        }
        .navigationTitle(Constants.appName)
    }

    var sidebar: some View {
        List {
            Section("App") {
                NavigationLink {
                    WelcomeView().limitMinSize()
                } label: {
                    Label("Welcome", systemImage: "house")
                }
            }
            DeviceList()
        }
        .listStyle(.sidebar)
    }
}

private struct DeviceList: View {
    @StateObject var vm = devManager
    @State var openRegPanel = false

    var body: some View {
        Group {
            Section("Devices") {
                ForEach(vm.deviceList) { device in
                    NavigationLink {
                        DeviceView(udid: device.udid)
                            .limitMinSize()
                            .id(device.udid)
                    } label: {
                        Label(device.deviceName, systemImage: device.deviceSystemIcon)
                    }
                }
                Label("Add Device", systemImage: "apps.iphone.badge.plus")
                    .sheet(isPresented: $openRegPanel) {
                        RegisterSheetView()
                    }
                    .onTapGesture { openRegPanel = true }
            }
        }
    }
}

extension UUID: Comparable {
    public static func < (lhs: UUID, rhs: UUID) -> Bool {
        lhs.uuidString < rhs.uuidString
    }
}
