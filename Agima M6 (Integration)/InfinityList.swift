//
//  InfinityList.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 23.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class InfinityList<T: Loadable> {
    
    let musicProvider: MusicProvider
    let items: BehaviorRelay<[T]> = BehaviorRelay(value: [])
    let allItemsFetched: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let loadingInProgress: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let state: Observable<String>
    
    let portionSize: Int
    
    private var endpoint: T.EndpointType?
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.kravchuk.infinity_list_queue.\(T.self)"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(musicProvider: MusicProvider, portionSize: Int = 50) {
        self.musicProvider = musicProvider
        self.portionSize = portionSize
        
        state = Observable.combineLatest(allItemsFetched, loadingInProgress) { allItemsFetched, loadingInProgress in
            if allItemsFetched {
                return "Done"
            } else {
                return loadingInProgress ? "Loading" : "Waiting"
            }
        }
    }
    
    func reset() {
        self.endpoint = nil
        queue.cancelAllOperations()
        items.accept([])
        allItemsFetched.accept(false)
    }
    
    func fetch(endpoint: T.EndpointType?) {
        reset()
        self.endpoint = endpoint
        fetchNextPortion()
    }

    func fetchNextPortion() {
        guard let endpoint = endpoint else { return }
        if allItemsFetched.value { return }
        loadingInProgress.accept(true)
        
        let op = LoadingOperation<T>(musicProvider: musicProvider, endpoint: endpoint, portionSize: portionSize, delegate: self)
        let acceptResult = BlockOperation {
            self.loadingInProgress.accept(false)
            self.appendNewItems(op.result!)
        }
        acceptResult.addDependency(op)
        queue.addOperation(op)
        queue.addOperation(acceptResult)
        
    }
    
    private func appendNewItems(_ newItems: [T]) {
        self.items.accept(self.items.value + newItems)
        if newItems.count < self.portionSize {
            self.allItemsFetched.accept(true)
            self.queue.cancelAllOperations()
            loadingInProgress.accept(false)
        }
    }
    
    
}

extension InfinityList: LoadingOperationDataSource {
    var numberOfLoadedItems: Int {
        return items.value.count
    }
}
protocol Request {
    var requestBaseURLComponents: URLComponents { get }
}
protocol InfinityListRequest {
    func makeRequest(offset: Int, limit: Int) -> URL
}

extension InfinityListRequest where Self: Request {
    func makeRequest(offset: Int, limit: Int) -> URL {
        var components = requestBaseURLComponents
        components.queryItems = (components.queryItems ?? []) +
            [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ]
        return components.url!
    }
}

protocol Loadable {
    associatedtype EndpointType: AppleMusicEndpoint, InfinityListRequest
}
