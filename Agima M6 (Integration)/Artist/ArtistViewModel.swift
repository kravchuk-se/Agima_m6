//
//  ArtistViewModel.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 16.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation
//import RxCocoa
//import RxSwift

final class ArtistViewModel {
    
    let musicProvider: MusicProvider = MusicAPI()
    let artist: Artist
    
    var onSongsChange: (()->())?
    var onAlbumsChange: (()->())?
    
    private let maxNumberOfAlbums = 10
    private let maxNumberOfSongs = 10
    private (set) var albums: [Album] = []
    private (set) var songs: [Song] = []
    
    init(artist: Artist) {
        self.artist = artist
    }
    
    func fetchAlbums() {
        musicProvider.getAlbums(for: artist, limit: maxNumberOfAlbums) { albums in
            DispatchQueue.main.async {
                self.albums = albums
                self.onAlbumsChange?()
            }
        }
    }
    
    func fetchSongs() {
        musicProvider.getSongs(for: artist, limit: maxNumberOfSongs) { songs in
            DispatchQueue.main.async {
                self.songs = songs
                self.onSongsChange?()
            }
        }
    }
    
}
