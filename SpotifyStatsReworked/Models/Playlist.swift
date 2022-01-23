//
//  Playlist.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 23.01.22.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let id: String
    let `public`: Bool
    let owner: PlaylistOwner
    let tracks: PlaylistTracks
    let collaborative: Bool
    let images: [Image]
    let name: String
}

struct PlaylistOwner: Codable {
    let id: String
    let display_name: String
}

struct PlaylistTracks: Codable {
    let total: Int
}
