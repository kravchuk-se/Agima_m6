//
//  LoadingOperation.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 17.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

protocol LoadingOperationDelegate: AnyObject {
    var numberOfLoadedItems: Int { get }
}

final class LoadingOperation: Operation {
    
    enum State {
        case ready
        case executing
        case finished
    }
    
    var result: [Artist]?
    weak var delegate: LoadingOperationDelegate?

    let musicProvider: MusicProvider
    let searchTerm: String
    let portionSize: Int
    
    private (set) var state: State = .ready {
        willSet {
            willChangeValue(forKey: "isReady")
            willChangeValue(forKey: "isExecuting")
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isReady")
            didChangeValue(forKey: "isExecuting")
            didChangeValue(forKey: "isFinished")
        }
    }

    init(searchTerm: String, musicProvider: MusicProvider, portionSize: Int, delegate: LoadingOperationDelegate) {
        self.delegate = delegate
        self.musicProvider = musicProvider
        self.searchTerm = searchTerm
        self.portionSize = portionSize
        super.init()
    }
    
    override var isAsynchronous: Bool { true }
    
    override var isReady:     Bool { state == .ready }
    override var isExecuting: Bool { state == .executing }
    override var isFinished:  Bool { state == .finished }
    

    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        guard let dataSource = delegate else {
            state = .finished
            return
        }
        state = .executing
        musicProvider.search(artistName: searchTerm,
                                        limit: portionSize,
                                        offset: dataSource.numberOfLoadedItems,
                                        completion: { artists in
            
            print("requested: \(self.searchTerm), loaded \(artists.count) items")
            self.result = artists
            self.state = .finished
        })
    }
    
}
