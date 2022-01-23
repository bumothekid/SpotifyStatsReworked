//
//  APICaller.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 19.01.22.
//

import Foundation
import UIKit

class APICaller {
    static let shared = APICaller()
    
    var baseRequest: URLRequest?
    
    struct Constants {
        static let baseApiUrl = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
    }
    
    enum ApiTimeWindow {
        case short_term
        case medium_term
        case long_term
    }
    
    private init() {}
    
    private func createGETRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken(completion: { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        })
    }
    
    private func createGETRequest(with url: URL?, type: HTTPMethod) async -> URLRequest {
        return await withCheckedContinuation { continuation in
            createGETRequest(with: url, type: type) { result in
                continuation.resume(returning: result)
            }
        }
    }
    

//    func getCurrentSong(completion: @escaping (Result<CurrentSong, Error>) -> Void) {
//        createGETRequest(with: URL(string: Constants.baseApiUrl + "/me/player/currently-playing"), type: .GET) { baseRequest in
//            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
//                guard let data = data, error == nil else {
//                    completion(.failure(APIError.failedToGetData))
//                    return
//                }
//
//                do {
//                    let result = try JSONDecoder().decode(CurrentSong.self, from: data)
//                    completion(.success(result))
//                }
//                catch {
//                    completion(.failure(error))
//                }
//            }
//            task.resume()
//        }
//    }
    
    func getCurrentSong(completion: @escaping (Result<CurrentSong, Error>) -> Void) {
        createGETRequest(with: URL(string: Constants.baseApiUrl + "/me/player/currently-playing"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(CurrentSong.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getCurrentSong() async throws -> CurrentSong {
        return try await withCheckedThrowingContinuation { continuation in
            getCurrentSong() { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public func getRecetlyListenedSongs(amount: Int, completion: @escaping (Result<RecentlyListenedSongs, Error>) -> Void) {
        createGETRequest(with: URL(string: Constants.baseApiUrl + "/me/player/recently-played?limit=\(amount)"), type: .GET) {baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    return
                }
            
                do {
                    let result = try JSONDecoder().decode(RecentlyListenedSongs.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecetlyListenedSongs(amount: Int) async throws -> RecentlyListenedSongs {
        return try await withCheckedThrowingContinuation { continuation in
            getRecetlyListenedSongs(amount: amount) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    public func getCurrentlyListeningDevice() async throws -> String {
        let baseRequest = await createGETRequest(with: URL(string: Constants.baseApiUrl + "/me/player/devices"), type: .GET)
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data1 = data, error == nil else {
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(ListeningDevices.self, from: data1)
                    
                    for device in result.devices {
                        if device.is_active {
                            continuation.resume(with: .success(device.name))
                        }
                    }
                }
                catch {
                    print(error)
                    continuation.resume(with: .failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getTopArtists(since: ApiTimeWindow, limit: Int, offset: Int = 0) async throws -> TopArtists {
        let baseRequest = await createGETRequest(with: URL(string: Constants.baseApiUrl + "/me/top/artists?time_range=\(since)&limit=\(limit)&offset=\(offset)"), type: .GET)
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data1 = data, error == nil else {
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(TopArtists.self, from: data1)
                    
                    continuation.resume(with: .success(result))
                }
                catch {
                    continuation.resume(with: .failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getUserPlaylists(limit: Int) async throws -> UserPlaylists {
        let baseRequest = await createGETRequest(with: URL(string: Constants.baseApiUrl + "/me/playlists?limit=\(limit)"), type: .GET)
        
        return try await withCheckedThrowingContinuation({ continuation in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data1 = data, error == nil else {
                    continuation.resume(with: .failure(error!))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserPlaylists.self, from: data1)
                    
                    continuation.resume(with: .success(result))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
            task.resume()
        })
    }
}
