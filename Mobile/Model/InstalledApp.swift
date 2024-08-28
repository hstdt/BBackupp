//
//  InstalledApp.swift
//  BBackupp
//
//  Created by tdt on 8/28/24.
//

import Foundation

struct InstalledApp: Sendable {
    var identifier: String
    var icon: Data?

    struct _iTunesMetadata: Sendable {
        var id: Int
        var name: String
        var artist: String?
        var version: String?
        var countryCode: String?
        var genre: String?
        var genreId: Int?
        var subgenres: [String]?

        struct DownloadInfo: Codable {
            var account: String?
            var purchaseDate: String?
        }

        var downloadInfo: DownloadInfo?
    }

    var metadata: _iTunesMetadata?
}

extension InstalledApp: Identifiable {
    var id: String {
        identifier
    }
}
