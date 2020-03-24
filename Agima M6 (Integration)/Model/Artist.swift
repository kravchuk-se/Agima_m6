//
//  Artist.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 16.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

struct Artist {
    let name: String
    let artistId: Int
    let primaryGenreName: String?
}

extension Artist: JSONDecodable {
    init?(data: NSDictionary) {
        
        guard let name = data["artistName"] as? String,
            let artistId = data["artistId"] as? Int else
        { return nil }
        
        self.name = name
        self.artistId = artistId
        self.primaryGenreName = data["primaryGenreName"] as? String
        
    }
}
