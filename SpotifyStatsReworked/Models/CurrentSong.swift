//
//  CurrentlyPlayingResponse.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 19.01.22.
//

import Foundation

struct CurrentSong: Codable {
    let is_playing: Bool
    let currently_playing_type: String
    let progress_ms: Int
    let item: CurrentSongItem
}

struct CurrentSongItem: Codable {
    let id: String
    let name: String
    let album: Album
    let artists: [Artist]
    let is_local: Bool
    let popularity: Int
    let duration_ms: Int
}
