//
//  ArtistEndpoint.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 23.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

enum ArtistEndpoint {
    case searchByName(_ name: String)
}

extension ArtistEndpoint: AppleMusicEndpoint {
    typealias Entity = Artist
}

extension Artist: Loadable {
    typealias EndpointType = ArtistEndpoint
}

extension ArtistEndpoint: Request, InfinityListRequest {
    var requestBaseURLComponents: URLComponents {
        switch self {
        case .searchByName(let name):
            var components = MusicAPI.baseURLComponents
            components.path = "/search"
            components.queryItems =
                [
                    URLQueryItem(name: "term", value: name),
                    URLQueryItem(name: "entity", value: "musicArtist"),
                    URLQueryItem(name: "country", value: "RU")
                ]
            return components
        }
    }
}


