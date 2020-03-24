//
//  Album.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 16.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

struct Album: JSONDecodable {
    let collectionName: String
    let artworkUrl60: URL
    let artworkUrl100: URL
    let collectionPrice: Double
    let releaseDate: Date
    
    init?(data: NSDictionary) {
        guard let type = data["wrapperType"] as? String, type == "collection" else { return nil }
        guard let collectionName = data["collectionName"] as? String,
            let artworkUrl60 = data["artworkUrl60"] as? String,
            let artworkUrl100 = data["artworkUrl100"] as? String,
            let collectionPrice = data["collectionPrice"] as? Double,
            let releaseDate = data["releaseDate"] as? String  else
        { return nil }
        
        guard let url60 = URL(string: artworkUrl60), let url100 = URL(string: artworkUrl100) else { return nil }
        guard let date = MusicAPI.dateFormatter.date(from: releaseDate) else { return nil }
        
        self.collectionName = collectionName
        self.artworkUrl60 = url60
        self.artworkUrl100 = url100
        self.collectionPrice = collectionPrice
        self.releaseDate = date
        
    }
}
