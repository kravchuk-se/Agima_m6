//
//  InfiniteList.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 23.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class InfiniteList<T: Loadable> {
    
    let musicProvider: MusicProvider
    let items: BehaviorRelay<[T]> = BehaviorRelay(value: [])
    let allItemsFetched: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let loadingInProgress: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let state: Observable<String>
    
    let portionSize: Int
    
    private let newItemsRequested: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private var endpoint: T.EndpointType?
    
    private let bag = DisposeBag()
    
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
        
        Observable<Bool>.combineLatest(loadingInProgress, newItemsRequested, allItemsFetched) { inProgress, itemsRequested, done in
                return !inProgress && itemsRequested && !done
            }
            .filter({ $0 })
            .compactMap({ _ in
                return self.endpoint
            })
            .flatMap({ endpoint -> Observable<[T]> in
                return Observable<[T]>.create { observer in
                    let task = self.musicProvider.fetch(endpoint,
                                                offset: self.items.value.count,
                                                limit: self.portionSize) {
                                                    newArtists in

                        observer.onNext(newArtists as! [T])
                        observer.onCompleted()
                    }
                    return Disposables.create {
                        task.cancel()
                    }
                }
            })
            .subscribe(onNext: appendNewItems)
            .disposed(by: bag)
        
    }
    
    func reset() {
        self.endpoint = nil
        newItemsRequested.accept(false)
        allItemsFetched.accept(false)
        items.accept([])
    }
    
    func fetch(endpoint: T.EndpointType?) {
        reset()
        self.endpoint = endpoint
        fetchNextPortion()
    }

    func fetchNextPortion() {
        newItemsRequested.accept(true)
    }
    
    private func appendNewItems(_ newItems: [T]) {
        self.items.accept(self.items.value + newItems)
        if newItems.count < self.portionSize {
            self.allItemsFetched.accept(true)
            loadingInProgress.accept(false)
        }
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
