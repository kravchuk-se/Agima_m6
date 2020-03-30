//
//  ArtistViewModel.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 16.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

final class SongViewModel {
    let song: Song
    var loadingState: DownloadState = .notStarted
    var fileURL: URL?
    
    init(song: Song) {
        self.song = song
    }
}

final class ArtistViewModel {
    
    let musicProvider: MusicProvider = MusicAPI()
    let artist: Artist
    
    var onSongsChange: (()->())?
    var onAlbumsChange: (()->())?
    
    private let maxNumberOfAlbums = 10
    private let maxNumberOfSongs = 10
    private (set) var albums: [Album] = []
    private (set) var songs: [SongViewModel] = []
    
    init(artist: Artist) {
        self.artist = artist
    }
    
    func fetchAlbums() {
        musicProvider.fetch(AlbumEndpoint.searchByArtist(artist: artist), offset: 0, limit: 10){ albums in
            DispatchQueue.main.async {
                self.albums = albums
                self.onAlbumsChange?()
            }
        }
    }
    
    func fetchSongs() {
        musicProvider.fetch(SongEndpoint.searchByArtist(artist: artist), offset: 0, limit: 10) { songs in
            DispatchQueue.main.async {
                self.songs = songs.map({ SongViewModel.init(song: $0) })
                self.onSongsChange?()
            }
        }
    }
    
}
