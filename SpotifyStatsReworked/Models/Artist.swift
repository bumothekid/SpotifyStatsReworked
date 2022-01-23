//
//  Artist.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 19.01.22.
//

import Foundation

struct Artist: Codable {
    let genres: [String]?
    let images: [Image]?
    let id: String
    let name: String
}
