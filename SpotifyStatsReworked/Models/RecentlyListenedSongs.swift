//
//  RecentlyListenedSongs.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 20.01.22.
//

import Foundation

struct RecentlyListenedSongs: Codable {
    let items: [RecentlyListenedSong]
}

struct RecentlyListenedSong: Codable {
    let track: RecentlyListenedSongItem
    let played_at: String
}

struct RecentlyListenedSongItem: Codable {
    let id: String
    let name: String
    let album: Album
    let artists: [Artist]
    let is_local: Bool
    let popularity: Int
    let duration_ms: Int
}
