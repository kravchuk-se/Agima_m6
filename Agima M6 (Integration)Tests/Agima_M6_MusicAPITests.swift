//
//  Agima_M6__Integration_Tests.swift
//  Agima M6 (Integration)Tests
//
//  Created by Kravchuk Sergey on 13.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import XCTest
@testable import Agima_M6__Integration_

// TODO: Rewrite test

//class Agima_M6_MusicAPITests: XCTestCase {
//
//    var sut: MusicAPI!
//
//    override func setUp() {
//        sut = MusicAPI()
//    }
//
//    override func tearDown() {
//        sut = nil
//    }
//
//    func testURL() {
//
//        let url = sut.makeURLForSearch(artistName: "lana", limit: 50, offset: 0)
//        XCTAssert(url != nil, "Invalid url")
//    }
//
//    func testLoading() {
//
//        let exp = expectation(description: "Loading completion handler was performed")
//
//        sut.search(artistName: "lana", limit: 50, offset: 0) { artists in
//            exp.fulfill()
//            XCTAssert(artists.count > 0, "Artists data is empty!")
//            XCTAssert(artists.count <= 50, "To many artists in response")
//        }
//
//        waitForExpectations(timeout: 5.0, handler: nil)
//
//    }
//
//    func testAlbumsLoading() {
//
//        let exp = expectation(description: "Loading completion handler was performed")
//
//        let artist = Artist(name: "Lana Del Rey",
//                            artistId: 464296584,
//                            primaryGenreName: "Alternative")
//
//        sut.getAlbums(for: artist, limit: 10) { albums in
//            exp.fulfill()
//            XCTAssert(albums.count > 0, "Albums must not be empty")
//        }
//
//        waitForExpectations(timeout: 5.0, handler: nil)
//
//    }
//
//    func testSongsLoading() {
//
//        let exp = expectation(description: "Loading completion handler was performed")
//
//        let artist = Artist(name: "Lana Del Rey",
//                            artistId: 464296584,
//                            primaryGenreName: "Alternative")
//
//        sut.getSongs(for: artist, limit: 10) { songs in
//            exp.fulfill()
//            XCTAssert(songs.count > 0, "Songs must not be empty")
//        }
//
//        waitForExpectations(timeout: 5.0, handler: nil)
//
//    }
//
//    func testInvalidLoading() {
//
//        let exp = expectation(description: "Loading completion handler was performed")
//
//        sut.search(artistName: "somedefinetelyinvalidquerrywithimpossiblename", limit: 50, offset: 0) { artists in
//            exp.fulfill()
//            XCTAssert(artists.count == 0, "Artists data is not empty!")
//        }
//
//        waitForExpectations(timeout: 5.0, handler: nil)
//
//    }

//}
