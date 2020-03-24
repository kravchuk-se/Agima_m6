//
//  MusicProvider.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 18.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    init?(data: NSDictionary)
}

protocol AppleMusicEndpoint: Request {
    associatedtype Entity: JSONDecodable
}

protocol MusicProvider {
    func fetch<T>(_ endpoint: T, offset: Int, limit: Int, completion: @escaping (([T.Entity]) -> ())) where T: AppleMusicEndpoint, T: InfinityListRequest
}
