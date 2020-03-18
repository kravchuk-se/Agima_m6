//
//  Agima_M6_ArtistViewModelTests.swift
//  Agima M6 (Integration)Tests
//
//  Created by Kravchuk Sergey on 18.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import XCTest
@testable import Agima_M6__Integration_

class Agima_M6_ArtistViewModelTests: XCTestCase {
    
    var sut: ArtistViewModel!
    
    override func setUp() {
        super.setUp()
        let artist = Artist(name: "Lana Del Rey", artistId: 464296584, primaryGenreName: "Alternative")
        sut = ArtistViewModel(artist: artist)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testLoading() {
        
        let songsExp = expectation(description: "Songs are loaded")
        let albumsExp = expectation(description: "Albums are loaded")
        let itemsLimit = 10
        
        sut.onSongsChange = {
            songsExp.fulfill()
        }
        sut.onAlbumsChange = {
            albumsExp.fulfill()
        }
        
        sut.fetchAlbums()
        sut.fetchSongs()
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssert(sut.songs.count == itemsLimit, "Must be a \(itemsLimit) songs")
        XCTAssert(sut.albums.count == itemsLimit, "Must be a \(itemsLimit) albums")
        
    }
    
}
