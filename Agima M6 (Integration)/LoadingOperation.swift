//
//  LoadingOperation.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 23.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation

protocol LoadingOperationDelegate: AnyObject {
    var numberOfLoadedItems: Int { get }
}

final class LoadingOperation<T: Loadable>: Operation {
    
    enum State {
        case ready
        case executing
        case finished
    }
    
    var endpoint: T.EndpointType
    var result: [T]?
    weak var delegate: LoadingOperationDelegate?
    let portionSize: Int
    let musicProvider: MusicProvider
    
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

    init(musicProvider: MusicProvider, endpoint: T.EndpointType, portionSize: Int, delegate: LoadingOperationDelegate) {
        self.musicProvider = musicProvider
        self.endpoint = endpoint
        self.delegate = delegate
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
        
        musicProvider.fetch(endpoint, offset: dataSource.numberOfLoadedItems, limit: portionSize) { result in
            self.result = (result as! [T])
            self.state = .finished
            print("requested: \(self.endpoint), loaded \(self.result?.count ?? 0) items")
        }
    
    }
    
}
