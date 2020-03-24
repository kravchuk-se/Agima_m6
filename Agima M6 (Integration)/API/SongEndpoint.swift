//
//  SongEndpoint.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 23.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

enum SongEndpoint {
    case searchByArtist(artist: Artist)
}

extension SongEndpoint: AppleMusicEndpoint {
    typealias Entity = Song
}

extension Song: Loadable {
    typealias EndpointType = SongEndpoint
}
extension SongEndpoint: Request, InfinityListRequest {
    var requestBaseURLComponents: URLComponents {
        switch self {
        case .searchByArtist(artist: let artist):
            var components = MusicAPI.baseURLComponents
            components.path = "/lookup"
            components.queryItems =
            [
                URLQueryItem(name: "id", value: "\(artist.artistId)"),
                URLQueryItem(name: "entity", value: "song"),
            ]
            return components
        }
    }
}

