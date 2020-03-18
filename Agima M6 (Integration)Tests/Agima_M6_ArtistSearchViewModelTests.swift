//
//  Agima_M6_ArtistSearchViewModelTests.swift
//  Agima M6 (Integration)Tests
//
//  Created by Kravchuk Sergey on 13.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import XCTest
import RxSwift

@testable import Agima_M6__Integration_

class Agima_M6_ArtistSearchViewModelTests: XCTestCase {
    
    var sut: ArtistSearchViewModel!
    
    override func setUp() {
        super.setUp()
        sut = ArtistSearchViewModel(portionSize: 50)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testLoad() {
        
        let api = MusicAPI()
        var test: [Artist] = []

        let portionSize = 50
        let numberOfPortions = 4

        let exp = expectation(description: "test data loaded")

        api.search(artistName: "lana", limit: portionSize * numberOfPortions, offset: 0) { artists in
            test = artists
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)
        let bag = DisposeBag()
        let exp1 = expectation(description: "All portions loaded")
        sut.artists.subscribe(onNext: { artists in
            if artists.count == portionSize * numberOfPortions {
                exp1.fulfill()
            }
            }).disposed(by: bag)

        sut.fetch(searchTerm: "lana")
        for _ in 0..<numberOfPortions - 1 {
            sut.fetchNextPortion()
        }
        
        wait(for: [exp1], timeout: 5.0)
        XCTAssert(sut.artists.value.count == test.count, "Arrays must be equal size (\(sut.artists.value.count) - \(test.count))")
        
        let left = sut.artists.value.sorted(by: { $0.artistId < $1.artistId })
        let right = test.sorted(by:  { $0.artistId < $1.artistId })
        for i in 0..<test.count {
            XCTAssert(left[i] == right[i], "Entities at index: \(i) must be equal")
        }
        
    }
    
    deinit {
        print("test case deallocated")
    }
    
}
