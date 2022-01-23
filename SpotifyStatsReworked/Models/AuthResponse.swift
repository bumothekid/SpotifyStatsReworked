//
//  AuthResponse.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 18.01.22.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let token_type: String
}
