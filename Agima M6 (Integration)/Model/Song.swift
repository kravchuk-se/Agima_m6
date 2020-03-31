//
//  Song.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 16.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

struct Song: JSONDecodable {
    let trackName: String
    let artworkUrl30: URL
    let artworkUrl60: URL
    let artworkUrl100: URL
    let trackPrice: Double
    let releaseDate: Date
    let artistName: String
    let previewUrl: URL
    
    init?(data: NSDictionary) {
        guard let type = data["wrapperType"] as? String, type == "track" else { return nil }
        guard let trackName = data["trackName"] as? String,
            let artworkUrl30 = data["artworkUrl30"] as? String,
            let artworkUrl60 = data["artworkUrl60"] as? String,
            let artworkUrl100 = data["artworkUrl100"] as? String,
            let previewUrl = data["previewUrl"] as? String,
            let artistName = data["artistName"] as? String,
            let trackPrice = data["trackPrice"] as? Double,
            let releaseDate = data["releaseDate"] as? String  else
        { return nil }
        
        guard let url30 = URL(string: artworkUrl30),
            let url60 = URL(string: artworkUrl60),
            let url100 = URL(string: artworkUrl100) else { return nil }
        guard let date = MusicAPI.dateFormatter.date(from: releaseDate) else { return nil }
        
        self.trackName = trackName
        self.artistName = artistName
        self.artworkUrl30 = url30
        self.artworkUrl60 = url60
        self.artworkUrl100 = url100
        self.trackPrice = trackPrice
        self.releaseDate = date
        self.previewUrl = URL(string: previewUrl)!
    }
}

extension Song: Equatable {
    
}
