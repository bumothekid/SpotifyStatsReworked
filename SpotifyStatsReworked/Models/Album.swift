//
//  Album.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 19.01.22.
//

import Foundation

struct Album: Codable {
    let id: String
    let artists: [Artist]
    let images: [Image]
    let release_date: String
    let name: String
}
