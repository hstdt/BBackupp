//
//  InstalledAppListView.swift
//  Mobile
//
//  Created by tdt on 8/28/24.
//

import Foundation
import SwiftUI

struct InstalledAppListView: View {
    let udid: Device.ID
    @State private var selection: String?

    var body: some View {
        List(selection: $selection) {
            InstalledAppListContentView(udid: udid)
        }
    }
}

private struct InstalledAppListContentView: View {
    let udid: Device.ID
    init(udid: Device.ID) {
        self.udid = udid
        self._installedApp = .init(wrappedValue: InstalledAppObservation.init(udid: udid))
    }

    @State private var installedApp: InstalledAppObservation

    var body: some View {
        if installedApp.apps.isEmpty {
            Color.clear // unavailable content
                .onAppear {
                    if installedApp.apps.isEmpty {
                        try? installedApp.fetchInstalledApp()
                    }
                }
        } else {
            content
        }
    }

    @ViewBuilder
    var content: some View {
        ForEach(installedApp.apps, id: \.id) { app in
            Label {
                let image = Image(systemName: "info.circle")
                let badge = Text(image)
                Text(app.metadata?.name ?? app.id)
                    .padding(.leading, 8)
                    .badge(badge)
                    .badgeProminence(.decreased)
            } icon: {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        if let data = app.icon, let icon = NSImage(data: data) {
                            Image(nsImage: icon)
                                .resizable()
                        } else {
                            Color.secondaryBackground.opacity(0.25)
                                .clipShape(.rect(cornerRadius: 4, style: .continuous))
                        }
                    }
            }
        }
    }
}
