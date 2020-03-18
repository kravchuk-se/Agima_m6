//
//  MusicProvider.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 18.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

protocol MusicProvider {
    func search(artistName: String, limit: Int, offset: Int, completion: @escaping ([Artist])->() )
    func getAlbums(for artist: Artist, limit: Int, completion: @escaping (([Album]) -> Void))
    func getSongs(for artist: Artist, limit: Int, completion: @escaping (([Song]) -> ()))
}
