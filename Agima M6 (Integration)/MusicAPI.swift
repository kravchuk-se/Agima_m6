//
//  MusicAPI.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 13.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

struct SearhResponse: Codable {
    let results: [Artist]
}

struct MusicAPI : MusicProvider {
    // https://itunes.apple.com/search?term=lana&entity=musicArtist&limit=50&offset=0
    
    static let dateFormatter: ISO8601DateFormatter = .init()
    
    private var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        return components
    }
    
    private (set) var urlSession = URLSession.shared
    
    func makeURLForSearch(artistName: String, limit: Int, offset: Int) -> URL? {
        
        let term = artistName.split(separator:" ").joined(separator: "+")

        var components = baseURLComponents
        components.path = "/search"
        components.queryItems =
            [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "entity", value: "musicArtist"),
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "country", value: "RU")
            ]
        
        return components.url
    }
    
    func makeURLForAblbums(artist: Artist, limit: Int) -> URL? {
        var components = baseURLComponents
        components.path = "/lookup"
        components.queryItems =
        [
            URLQueryItem(name: "id", value: "\(artist.artistId)"),
            URLQueryItem(name: "entity", value: "album"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        return components.url
    }
    
    func makeURLForSongs(artist: Artist, limit: Int) -> URL? {
        var components = baseURLComponents
        components.path = "/lookup"
        components.queryItems =
        [
            URLQueryItem(name: "id", value: "\(artist.artistId)"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        return components.url
    }
    
    func search(artistName: String, limit: Int, offset: Int, completion: @escaping ([Artist])->() ) {
        guard let url = makeURLForSearch(artistName: artistName, limit: limit, offset: offset) else {
            completion([])
            return
        }
        
        urlSession.dataTask(with: url) { data, response, error in
            guard let data = data, let json = try? JSONDecoder().decode(SearhResponse.self, from: data)  else {
                completion([])
                return
            }
            completion(json.results)
        }.resume()
    }
    
    func getAlbums(for artist: Artist, limit: Int, completion: @escaping (([Album]) -> Void)) {
        guard let url = makeURLForAblbums(artist: artist, limit: limit) else {
            completion([])
            return
        }
        
        urlSession.dataTask(with: url) { data, response, error in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data)) as? NSDictionary,
                let results = json["results"] as? [NSDictionary]  else {
                    completion([])
                    return
            }
            let albums = results.compactMap(Album.init)
            completion(albums)
        }.resume()
    }
    
    func getSongs(for artist: Artist, limit: Int, completion: @escaping (([Song]) -> ())) {
        guard let url = makeURLForSongs(artist: artist, limit: limit) else {
            completion([])
            return
        }
        urlSession.dataTask(with: url) { data, response, error in
            
            guard let data = data, let json = (try? JSONSerialization.jsonObject(with: data)) as? NSDictionary,
            let results = json["results"] as? [NSDictionary] else {
                completion([])
                return
            }
            
            let songs = results.compactMap(Song.init)
            completion(songs)
        }.resume()
    }
    
}
