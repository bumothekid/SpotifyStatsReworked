//
//  OverviewController.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 18.01.22.
//

import UIKit
import SDWebImage
import SwiftGifOrigin
import GoogleToolboxForMac

class OverviewController: UIViewController {
    
    let isSignedIn = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUser()
    }
    
    var recentSong: CurrentSong?
    var lastSong: RecentlyListenedSongs?
    var deviceName: String?
    var topArtists: TopArtists?
    var userPlaylists: UserPlaylists?
    var recentlyListenedSongs: RecentlyListenedSongs?
    
    enum ArtistString {
        case CurrentSong
        case MultipleSongs
    }
    
    // MARK: -- Scroll View
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    // MARK: -- Listening View
    
    var listeningView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryColor
        view.layer.cornerRadius = 15
        return view
    }()
    
    var listeningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    var listeningCoverImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    var listeningNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    var listeningArtistsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    var listeningCenterView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var listeningIndicatorGif: UIImageView = {
        let iv = UIImageView()
        iv.loadGif(asset: "Playing")
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    var listeningDeviceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    // Top Artists ScrollView
    
    var artistsLabel: UILabel = {
        let label = UILabel()
        let partOne = NSMutableAttributedString(string: "Top artists", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
        let partTwo = NSAttributedString(string: " past 4 weeks", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .semibold)])
        partOne.append(partTwo)
        label.attributedText = partOne
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    var artistsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var artistsScrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    // Playlists ScrollView
    
    var playlistsLabel: UILabel = {
        let label = UILabel()
        label.text = "Playlists"
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    var playlistsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var playlistsScrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    // Recently Listened
    
    var recentlyListenedLabel: UILabel = {
        let label = UILabel()
        label.text = "Recently listened on Spotify"
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    var recentlyListenedStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: -- Functions
    
    func checkUser() {
        guard AuthManager.shared.isSignedIn else {
            let vc = WelcomeController()
            
            self.navigationItem.hidesBackButton = true
            vc.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(vc, animated: true)
            navigationController?.tabBarController?.tabBar.isHidden = true
            return
        }
        
        AuthManager.shared.refreshAccessToken(completion: nil)
    
        Task {
            do {
                try await fetchData()
            } catch {
                print("An error occurred while fetching the data!\n\n\(error)")
                return
            }
            
            await checkData()
            
            configureViewComponents()
        }
    }
    
    func fetchData() async throws {
        do {
            do {
                self.recentSong = try await APICaller.shared.getCurrentSong()
                self.deviceName = try await APICaller.shared.getCurrentlyListeningDevice()
            } catch {
                do {
                    self.lastSong = try await APICaller.shared.getRecetlyListenedSongs(amount: 1)
                }
            }
            
            self.topArtists = try await APICaller.shared.getTopArtists(since: .short_term, limit: 50)
            self.userPlaylists = try await APICaller.shared.getUserPlaylists(limit: 50)
            self.recentlyListenedSongs = try await APICaller.shared.getRecetlyListenedSongs(amount: 50)
        } catch {
            print(error)
        }
    }
    
    func checkData() async {
        guard self.recentSong != nil || self.lastSong != nil else {
            print("An error occurred while fetching the currently listening song!")
            return
        }
        
        guard self.topArtists != nil else {
            print("An error occurred while fetching the top artists!")
            return
        }
        
        guard self.userPlaylists != nil else {
            print("An error occurred while fetching the user playlists!")
            return
        }
        
        guard self.recentlyListenedSongs != nil else {
            print("An error occurred while fetching the recently listened songs!")
            return
        }
    }
    
    func createArtistString(with artists: [Artist]) -> String {
        var first = true
        var artistsString = ""
        
        for artist in artists {
            if first {
                artistsString += artist.name
                first = false
            } else {
                artistsString += ", " + artist.name
            }
        }
        
        return artistsString
    }
    
    func stringToDate(string: String) -> Date {
//        var dateString = string
//        if let dotRange = dateString.range(of: ".") {
//          dateString.removeSubrange(dotRange.lowerBound..<dateString.endIndex)
//        }
//
//        print(dateString)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: "2022-01-20T18:13:47.672Z")!
        
        return date
    }
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = "Overview"
        
        navigationController?.navigationBar.setupNavigationBar()
        tabBarController?.tabBar.setupTabBar()
        
        navigationItem.largeTitleDisplayMode = .never
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: <#T##UIImage?#>, style: <#T##UIBarButtonItem.Style#>, target: <#T##Any?#>, action: <#T##Selector?#>)
        
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        view.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 2200)
        
        // Currently Listening
        
        let artistString = createArtistString(with: (recentSong != nil ? recentSong!.item.artists:lastSong!.items[0].track.artists))
        var listeningViewHeight: CGFloat = 145
        
        if recentSong != nil {
            switch recentSong!.is_playing {
            case true:
                listeningViewHeight = 175
                
                listeningLabel.text = "Currently listening on Spotify"
            default:
                listeningViewHeight = 175
                
                listeningIndicatorGif.image = UIImage(named: "Paused")
                
                listeningLabel.text = "Currently paused on Spotify"
            }
        } else {
            listeningLabel.text = "Last played on Spotify"
        }
        
        scrollView.addSubview(listeningView)
        listeningView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 15, paddingRight: -15, height: listeningViewHeight)
        
        listeningView.addSubview(listeningLabel)
        listeningLabel.anchor(top: listeningView.topAnchor, left: listeningView.leftAnchor, paddingTop: 7.5, paddingLeft: 7.5)
        
        listeningView.addSubview(listeningCoverImage)
        listeningCoverImage.anchor(top: listeningLabel.bottomAnchor, left: listeningView.leftAnchor, paddingTop: 7.5, paddingLeft: 7.5, width: 100, height: 100)
        
        listeningCoverImage.sd_setImage(with: recentSong != nil ? recentSong!.item.album.images[0].url:lastSong!.items[0].track.album.images[0].url, completed: nil)
        
        listeningView.addSubview(listeningNameLabel)
        listeningNameLabel.anchor(top: listeningLabel.bottomAnchor, left: listeningCoverImage.rightAnchor, right: listeningView.rightAnchor, paddingTop: 7.5, paddingLeft: 7.5, paddingRight: -7.5)
        
        listeningNameLabel.text = (recentSong != nil ? recentSong!.item.name:lastSong!.items[0].track.name)
        
        listeningView.addSubview(listeningArtistsLabel)
        listeningArtistsLabel.anchor(top: listeningNameLabel.bottomAnchor, left: listeningCoverImage.rightAnchor, right: listeningView.rightAnchor, paddingLeft: 7.5, paddingRight: -7.5)
        
        listeningArtistsLabel.text = artistString
        
        if deviceName != nil {
            listeningView.addSubview(listeningCenterView)
            listeningCenterView.anchor(top: listeningCoverImage.bottomAnchor, left: listeningView.leftAnchor, bottom: listeningView.bottomAnchor, paddingLeft: 7.5)
            
            listeningView.addSubview(listeningIndicatorGif)
            listeningIndicatorGif.anchor(left: listeningView.leftAnchor, paddingLeft: 7.5, width: 20, height: 20)
            listeningIndicatorGif.centerYAnchor.constraint(equalTo: listeningCenterView.centerYAnchor).isActive = true
            
            listeningView.addSubview(listeningDeviceLabel)
            listeningDeviceLabel.anchor(left: listeningIndicatorGif.rightAnchor, paddingLeft: 7.5)
            listeningDeviceLabel.centerYAnchor.constraint(equalTo: listeningIndicatorGif.centerYAnchor).isActive = true
            
            listeningDeviceLabel.text = deviceName
        }
        
        // Top Artists
        
        var placing = 1
        
        scrollView.addSubview(artistsLabel)
        artistsLabel.anchor(top: listeningView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: -15)
        
        scrollView.addSubview(artistsScrollView)
        artistsScrollView.addSubview(artistsStackView)
        artistsScrollView.anchor(top: artistsLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 7.5, paddingLeft: 15)
        
        artistsStackView.leadingAnchor.constraint(equalTo: artistsScrollView.leadingAnchor).isActive = true
        artistsStackView.trailingAnchor.constraint(equalTo: artistsScrollView.trailingAnchor).isActive = true
        artistsStackView.topAnchor.constraint(equalTo: artistsScrollView.topAnchor).isActive = true
        artistsStackView.bottomAnchor.constraint(equalTo: artistsScrollView.bottomAnchor).isActive = true
        artistsStackView.heightAnchor.constraint(equalTo: artistsScrollView.heightAnchor).isActive = true
        
        for artist in topArtists!.items {
            let artistView: UIView = {
                let view = UIView()
                view.backgroundColor = .secondaryColor
                view.layer.cornerRadius = 15
                return view
            }()
            
            let artistImage: UIImageView = {
                let iv = UIImageView()
                iv.clipsToBounds = true
                iv.layer.cornerRadius = 15
                iv.contentMode = .scaleAspectFill
                return iv
            }()
            
            let artistPlacingLabel: UILabel = {
                let label = UILabel()
                label.text = "#\(placing)"
                label.textColor = .white
                label.textAlignment = .left
                label.layer.shadowColor = UIColor.black.cgColor
                label.layer.shadowRadius = 3.0
                label.layer.shadowOpacity = 1.0
                label.layer.shadowOffset = CGSize(width: 0, height: 0)
                label.numberOfLines = 1
                label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
                return label
            }()
            
            let artistNameLabel: UILabel = {
                let label = UILabel()
                label.text = "\(artist.name)"
                label.textColor = .white
                label.textAlignment = .left
                label.layer.shadowColor = UIColor.black.cgColor
                label.layer.shadowRadius = 3.0
                label.layer.shadowOpacity = 1.0
                label.layer.shadowOffset = CGSize(width: 0, height: 0)
                label.numberOfLines = 2
                label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                return label
            }()
            
            artistView.anchor(width: 140, height: 165)
            
            artistView.addSubview(artistImage)
            artistImage.centerYAnchor.constraint(equalTo: artistView.centerYAnchor).isActive = true
            artistImage.centerXAnchor.constraint(equalTo: artistView.centerXAnchor).isActive = true
            artistImage.anchor(width: 140, height: 165)
            
            artistImage.sd_setImage(with: artist.images![0].url, completed: nil)
            
            artistView.addSubview(artistPlacingLabel)
            artistPlacingLabel.anchor(top: artistView.topAnchor, left: artistView.leftAnchor, paddingTop: 10, paddingLeft: 12.5)
            
            artistView.addSubview(artistNameLabel)
            artistNameLabel.anchor(left: artistView.leftAnchor, bottom: artistView.bottomAnchor, right: artistView.rightAnchor, paddingLeft: 7.5, paddingBottom: -10, paddingRight: -7.5)
            
            artistsStackView.addArrangedSubview(artistView)
            
            placing += 1
        }
        
        // Playlists ScrollView
        
        scrollView.addSubview(playlistsLabel)
        playlistsLabel.anchor(top: artistsScrollView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: -15)
        
        scrollView.addSubview(playlistsScrollView)
        playlistsScrollView.addSubview(playlistsStackView)
        playlistsScrollView.anchor(top: playlistsLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 7.5, paddingLeft: 15)
        
        playlistsStackView.leadingAnchor.constraint(equalTo: playlistsScrollView.leadingAnchor).isActive = true
        playlistsStackView.trailingAnchor.constraint(equalTo: playlistsScrollView.trailingAnchor).isActive = true
        playlistsStackView.topAnchor.constraint(equalTo: playlistsScrollView.topAnchor).isActive = true
        playlistsStackView.bottomAnchor.constraint(equalTo: playlistsScrollView.bottomAnchor).isActive = true
        playlistsStackView.heightAnchor.constraint(equalTo: playlistsScrollView.heightAnchor).isActive = true
        
        for playlist in userPlaylists!.items {
            let playlistView: UIView = {
                let view = UIView()
                view.backgroundColor = .secondaryColor
                view.layer.cornerRadius = 15
                return view
            }()
            
            let playlistImage: UIImageView = {
                let iv = UIImageView()
                iv.clipsToBounds = true
                iv.layer.cornerRadius = 10
                iv.contentMode = .scaleAspectFill
                return iv
            }()
            
            let playlistNameLabel: FadingLabel = {
                let label = FadingLabel()
                label.text = "\(playlist.name)"
                label.textColor = .white
                label.textAlignment = .left
                label.allowsDefaultTighteningForTruncation = true
                label.numberOfLines = 1
                label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                return label
            }()
            
            let playlistOwnerLabel: FadingLabel = {
                let label = FadingLabel()
                label.text = "\(playlist.owner.display_name)"
                label.textColor = .white
                label.textAlignment = .left
                label.allowsDefaultTighteningForTruncation = true
                label.numberOfLines = 1
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                return label
            }()
            
            let playlistPrivacyLabel: UILabel = {
                let label = UILabel()
                switch playlist.public {
                case true: label.text = "Public"
                default: label.text = "Private"
                }
                label.textColor = .white
                label.textAlignment = .left
                label.numberOfLines = 0
                label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                return label
            }()
            
            playlistView.anchor(width: 225, height: 110)
            
            playlistView.addSubview(playlistImage)
            playlistImage.anchor(top: playlistView.topAnchor, left: playlistView.leftAnchor, bottom: playlistView.bottomAnchor, paddingTop: 7.5, paddingLeft: 7.5, paddingBottom: -7.5)
            playlistImage.widthAnchor.constraint(equalTo: playlistImage.heightAnchor).isActive = true
            
            if playlist.images.indices.contains(0) {
                playlistImage.sd_setImage(with: playlist.images[0].url, completed: nil)
            }
            
            playlistView.addSubview(playlistNameLabel)
            playlistNameLabel.anchor(top: playlistView.topAnchor, left: playlistImage.rightAnchor, right: playlistView.rightAnchor, paddingTop: 7.5, paddingLeft: 7.5)
            
            playlistView.addSubview(playlistOwnerLabel)
            playlistOwnerLabel.anchor(top: playlistNameLabel.bottomAnchor, left: playlistImage.rightAnchor, right: playlistView.rightAnchor, paddingLeft: 7.5)
            
            playlistView.addSubview(playlistPrivacyLabel)
            playlistPrivacyLabel.anchor(left: playlistImage.rightAnchor, bottom: playlistView.bottomAnchor, right: playlistView.rightAnchor, paddingLeft: 7.5, paddingBottom: -7.5)
            
            playlistsStackView.addArrangedSubview(playlistView)
            
            // Recently Listened
            
            scrollView.addSubview(recentlyListenedLabel)
            recentlyListenedLabel.anchor(top: playlistsStackView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: -15)
            
            scrollView.addSubview(recentlyListenedStackView)
            recentlyListenedStackView.anchor(top: recentlyListenedLabel.bottomAnchor, left: view.leftAnchor, right:  view.rightAnchor, paddingTop: 7.5, paddingLeft: 15, paddingRight: -15)
            
            for song in recentlyListenedSongs!.items {
                let artistsString = createArtistString(with: song.track.artists)
                let timeStamp = stringToDate(string: song.played_at)
            }
        }
    }}
