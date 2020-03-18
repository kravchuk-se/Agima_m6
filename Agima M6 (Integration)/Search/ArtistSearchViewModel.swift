//
//  ArtistSearchViewModel.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 13.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ArtistSearchViewModel: LoadingOperationDelegate {
    
    var numberOfLoadedItems: Int {
        return artists.value.count
    }
    
    let artists: BehaviorRelay<[Artist]> = BehaviorRelay(value: [])
    let searchTerm: BehaviorRelay<String> = BehaviorRelay(value: "")
    let allItemsFetched: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let loadingInProgress: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let state: Observable<String>
    
    private let musicProvider: MusicProvider = MusicAPI()
    private let portionSize: Int
    private var queue: OperationQueue
    
    init(portionSize: Int = 50) {
        self.portionSize = portionSize
        queue = OperationQueue()
        queue.name = "Loading queue"
        queue.maxConcurrentOperationCount = 1
        
        state = Observable.combineLatest(searchTerm, loadingInProgress).map { (searchText, loadingInProgress) -> String in
            if searchText.isEmpty {
                return "Start typing for search"
            } else {
                return loadingInProgress ? "Loading" : "Done"
            }
        }
            
    }
    
    func fetchNextPortion() {
        if allItemsFetched.value { return }
        loadingInProgress.accept(true)
        let op = LoadingOperation(searchTerm: searchTerm.value, musicProvider: musicProvider, portionSize: portionSize, delegate: self)
        let acceptResult = BlockOperation {
            self.loadingInProgress.accept(false)
            self.appendNewItems(op.result ?? [])
        }
        acceptResult.addDependency(op)
        queue.addOperation(op)
        queue.addOperation(acceptResult)
    }
    
    private func appendNewItems(_ newArtists: [Artist]) {
        self.artists.accept(self.artists.value + newArtists)
        if newArtists.count < self.portionSize {
            self.allItemsFetched.accept(true)
            self.queue.cancelAllOperations()
            loadingInProgress.accept(false)
        }
    }
    
    func fetch(searchTerm: String) {
        queue.cancelAllOperations()
        self.searchTerm.accept(searchTerm)
        artists.accept([])
        allItemsFetched.accept(false)
        fetchNextPortion()
    }
    
}


