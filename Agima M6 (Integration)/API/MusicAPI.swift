//
//  MusicAPI.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 13.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

struct MusicAPI : MusicProvider {
    
    @discardableResult
    func fetch<T>(_ endpoint: T, offset: Int, limit: Int, completion: @escaping (([T.Entity]) -> ())) -> URLSessionDataTask where T : AppleMusicEndpoint, T : InfinityListRequest {
        let url = endpoint.makeRequest(offset: offset, limit: limit)
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? NSDictionary,
                let results = json["results"] as? [NSDictionary] {
                
                let result = results.compactMap{
                    T.Entity.init(data: $0)
                }
                completion(result)
                
            } else {
                fatalError("Oops")
            }
        }
        task.resume()
        return task
    }
    
    // https://itunes.apple.com/search?term=lana&entity=musicArtist&limit=50&offset=0
    
    static let dateFormatter: ISO8601DateFormatter = .init()
    
    static let baseURLComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        return components
    }()
    
    private (set) var urlSession = URLSession.shared
    
}
