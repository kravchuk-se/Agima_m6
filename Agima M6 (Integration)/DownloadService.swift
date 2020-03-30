//
//  DownloadService.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 24.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import Foundation


class Download {
    var isLoading: Bool = false
    var progress: Double = 0.0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    let song: Song
    
    init(song: Song) {
        self.song = song
    }
}


protocol DownloadServiceDelegate: AnyObject {
    func downloadService(_ downloadService: DownloadService, didUpdateSong song: Song, withProgress progress: Double)
    func downloadService(_ downloadService: DownloadService, didFinishDownloadingSong song: Song, to location: URL)
}

enum DownloadState {
    case done
    case loading(progress: Double)
    case paused(progress: Double)
    case notStarted
}

class DownloadService: NSObject {
    
    private var session: URLSession!
    private var loadings: [URL: Download] = [:]
    private let queue: OperationQueue
    
    weak var delegate: DownloadServiceDelegate?
    
    override init() {

        queue = OperationQueue()
        queue.name = "com.kravchuk.Agima.DownloadService"
        queue.maxConcurrentOperationCount = 1
        
        super.init()
        
        self.session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)
    }
    
    func start(song: Song) {
        if let old = loadings[song.previewUrl] {
            old.task?.cancel()
            old.isLoading = false
            old.progress = 0
        }
        
        let new = Download(song: song)
        new.isLoading = true
        loadings[song.previewUrl] = new
        
        new.task = session.downloadTask(with: song.previewUrl)
        new.task?.resume()
    }
    
    func state(of song: Song) -> DownloadState {
        guard let download = loadings[song.previewUrl] else { return .notStarted }
        
        if download.isLoading {
            return .loading(progress: download.progress)
        } else {
            return download.progress == 100.0 ? .done : .paused(progress: download.progress)
        }
    }
    
    func pause(song: Song) {
        
        guard let download = loadings[song.previewUrl] else { return }
        
        download.isLoading = false
        download.task?.cancel(byProducingResumeData: { resumeData in
            download.resumeData = resumeData
        })
        
        delegate?.downloadService(self, didUpdateSong: song, withProgress: download.progress)
        
    }
    
    func resume(song: Song) {
        
        guard let download = loadings[song.previewUrl] else { return }
        guard let resumeData = download.resumeData else { return }
        
        download.isLoading = true
        
        download.task = session.downloadTask(withResumeData: resumeData)
        download.task?.resume()
    }
    
}

extension DownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let originalUrl = downloadTask.currentRequest?.url,
        let download = loadings[originalUrl] else { return }
        download.isLoading = false
        download.progress = 100
        
        delegate?.downloadService(self, didFinishDownloadingSong: download.song, to: location)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let originalUrl = downloadTask.currentRequest?.url,
        let download = loadings[originalUrl] else { return }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        download.progress = progress
        
        delegate?.downloadService(self, didUpdateSong: download.song, withProgress: progress)
    }
}
