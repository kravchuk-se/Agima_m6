//
//  Artist.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 16.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

struct Artist: Equatable, Codable {
    let name: String
    let artistId: Int
    let primaryGenreName: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "artistName"
        case artistId
        case primaryGenreName
    }
}
