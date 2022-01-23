//
//  ListeningDevicesResponse.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 22.01.22.
//

import Foundation

struct ListeningDevices: Codable {
    let devices: [ListeningDevice]
}

struct ListeningDevice: Codable {
    let name: String
    let id: String
    let type: String
    let is_active: Bool
}
