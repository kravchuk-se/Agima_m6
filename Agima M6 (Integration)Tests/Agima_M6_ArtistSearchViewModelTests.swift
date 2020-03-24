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
    
    var sut: InfinityList<Artist>!
    
    let portionSize = 50
    let numberOfPortions = 4
    let artistName = "mike"
    
    override func setUp() {
        super.setUp()
        sut = InfinityList<Artist>(portionSize: portionSize)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testLoad() {
        
        let api = MusicAPI()
        var test: [Artist] = []

        

        let exp = expectation(description: "test data loaded")

        api.fetch(ArtistEndpoint.searchByName(artistName), offset: 0, limit: portionSize * numberOfPortions) { (artists) in
            test = artists
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)
        let bag = DisposeBag()
        let exp1 = expectation(description: "All portions loaded")
        sut.items.subscribe(onNext: { [weak self] artists in
            if artists.count == self!.portionSize * self!.numberOfPortions {
                exp1.fulfill()
            }
            }).disposed(by: bag)

        sut.fetch(endpoint: .searchByName(artistName))
        for _ in 0..<numberOfPortions - 1 {
            sut.fetchNextPortion()
        }
        
        wait(for: [exp1], timeout: 5.0)
        
        let result = sut.items.value
        
        XCTAssert(result.count == test.count, "Arrays must be equal size (\(result.count) - \(test.count))")
        
        guard result.count == test.count else { return }
        
        let left = result.sorted(by: { $0.artistId < $1.artistId })
        let right = test.sorted(by:  { $0.artistId < $1.artistId })
        for i in 0..<test.count {
            XCTAssert(left[i] == right[i], "Entities at index: \(i) must be equal")
        }
        
    }
    
    deinit {
        print("test case deallocated")
    }
    
}

extension Artist: Equatable {
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
        lhs.artistId == rhs.artistId
    }
}
