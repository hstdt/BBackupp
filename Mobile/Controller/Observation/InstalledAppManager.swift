//
//  InstalledAppManager.swift
//  Mobile
//
//  Created by tdt on 8/28/24.
//

import Foundation
import Observation

@MainActor @Observable
final class InstalledAppObservation {
    @ObservationIgnored
    let udid: Device.ID
    init(udid: Device.ID) {
        self.udid = udid
    }

    var apps: [InstalledApp] = []

    func fetchInstalledApp() throws {
        guard let apps = amdManager.listApplications(udid: udid, connection: .any) else { return }
        self.apps = apps.compactMap { bundleIdentifier, value -> InstalledApp? in
            guard let value = value.value as? [String: AnyCodable] else { return nil }
            var app = InstalledApp(identifier: bundleIdentifier)

            if let icon = value["PlaceholderIcon"]?.value as? Data {
                app.icon = icon
            }

            if let iTunesMetadataData = value["iTunesMetadata"]?.value as? Data,
               let object = try? PropertyListSerialization.propertyList(from: iTunesMetadataData, format: nil ) as? [String: Any] {
                guard let itemId = object["itemId"] as? Int else { return app }
                guard let itemName = object["itemName"] as? String else  { return app }

                var metadata = InstalledApp._iTunesMetadata.init(id: itemId, name: itemName)

                if let artistName = object["artistName"] as? String {
                    metadata.artist = artistName
                }
                if let bundleShortVersionString = object["bundleShortVersionString"] as? String {
                    metadata.version = bundleShortVersionString
                }

                if let storefrontCountryCode = object["storefrontCountryCode"] as? String {
                    metadata.countryCode = storefrontCountryCode
                }

                if let genre = object["genre"] as? String {
                    metadata.genre = genre
                }
                if let genreId = object["genreId"] as? Int {
                    metadata.genreId = genreId
                }

                if let subgenres = object["subgenres"] as? [String] {
                    metadata.subgenres = subgenres
                }

                if let downloadInfo = object["com.apple.iTunesStore.downloadInfo"] as? [String: Any] {
                    var account: String? = nil

                    var info: InstalledApp._iTunesMetadata.DownloadInfo = .init()
                    if account == nil, let accountInfo = downloadInfo["accountInfo"] as? [String: Any], let getAccount = accountInfo["AppleID"] as? String, !getAccount.isEmpty {
                        account = getAccount
                    }

                    if account == nil,  let getAccount = object["apple-id"] as? String, !getAccount.isEmpty {
                        account = getAccount
                    }
                    info.account = account

                    if let purchaseDate = downloadInfo["purchaseDate"] as? String {
                        info.purchaseDate = purchaseDate
                    }
                    metadata.downloadInfo = info
                }
                app.metadata = metadata
            }
            return app
        }
    }
}
