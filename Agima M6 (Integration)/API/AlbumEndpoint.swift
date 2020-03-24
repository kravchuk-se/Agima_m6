//
//  AlbumEndpoint.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 23.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

enum AlbumEndpoint {
    case searchByArtist(artist: Artist)
}

extension AlbumEndpoint: AppleMusicEndpoint {
    typealias Entity = Album
}

extension Album: Loadable {
    typealias EndpointType = AlbumEndpoint
}
extension AlbumEndpoint: Request, InfinityListRequest {
    var requestBaseURLComponents: URLComponents {
        switch self {
        case .searchByArtist(artist: let artist):
            var components = MusicAPI.baseURLComponents
            components.path = "/lookup"
            components.queryItems =
            [
                URLQueryItem(name: "id", value: "\(artist.artistId)"),
                URLQueryItem(name: "entity", value: "album"),
            ]
            return components
        }
    }
}
