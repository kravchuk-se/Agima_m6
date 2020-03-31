//
//  ArtistViewController.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 16.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

import AVFoundation

class ArtistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ArtistViewModel!
    
    private let bag = DisposeBag()
    private var downloadService: DownloadService!
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        title = viewModel.artist.name

        tableView.dataSource = self
        tableView.delegate = self
        
        viewModel.onAlbumsChange = { [weak self] in
            self?.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
        }
        viewModel.onSongsChange = { [weak self] in
            self?.tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
        }
        
        viewModel.fetchSongs()
        viewModel.fetchAlbums()
        
        downloadService = DownloadService()
        downloadService.delegate = self
        
    }
    
    private func showAllSongs() {
        let vc = InfinityListViewController(
                list: InfinityList<Song>(musicProvider: viewModel.musicProvider),
                endpoint: .searchByArtist(artist: viewModel.artist))
        vc.title = "All songs"
        vc.cellConfiguration = { song, cell in
            cell.textLabel?.text = song.trackName
            cell.detailTextLabel?.text = "\(song.releaseDate)"
        }
        show(vc, sender: nil)
    }
    
    private func showAllAlbums() {
        let vc = InfinityListViewController(
            list: InfinityList<Album>(musicProvider: viewModel.musicProvider),
            endpoint: .searchByArtist(artist: viewModel.artist))
        vc.title = "All albums"
        vc.cellConfiguration = { album, cell in
            cell.textLabel?.text = album.collectionName
            cell.detailTextLabel?.text = "\(album.releaseDate)"
        }
        show(vc, sender: nil)
    }
}

// MARK: - Table View
extension ArtistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return viewModel.songs.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumsCell", for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
            let song = viewModel.songs[indexPath.row].song
            cell.songTitleLabel?.text = song.trackName
            cell.artistNameLabel?.text = song.artistName
            cell.delegate = self
            
            let loadingState = viewModel.songs[indexPath.row].loadingState
            switch loadingState {
            case .done:
                cell.downloadButton.loadingState = .done
            case .loading(progress: let progress):
                cell.downloadButton.loadingState = .inProgress
                cell.downloadButton.progress = CGFloat(progress)
            case .paused(progress: let progress):
                cell.downloadButton.loadingState = .paused
                cell.downloadButton.progress = CGFloat(progress)
            case .notStarted:
                cell.downloadButton.loadingState = .stoped
                cell.downloadButton.progress = 0
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 160
        default:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! TableSectionHeaderView
            header.textLabel?.text = "Top albums"
            header.button.setTitle("See all", for: .normal)
            header.buttonAction = { [weak self] _ in
                self?.showAllAlbums()
            }
            return header
        case 1:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! TableSectionHeaderView
            header.textLabel?.text = "Top songs"
            header.button.setTitle("See all", for: .normal)
            header.buttonAction = { [weak self] _ in
                self?.showAllSongs()
            }
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let view = view as! TableSectionHeaderView
        view.textLabel?.font = .boldSystemFont(ofSize: 20)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension ArtistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let songViewModel = viewModel.songs[indexPath.row]
        if let fileURL = songViewModel.fileURL {
            
            try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try! AVAudioSession.sharedInstance().setActive(true)
            
            try! player = AVAudioPlayer(contentsOf: fileURL, fileTypeHint: "m4a")
            player?.play()
            
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = cell as! AlbumsTableViewCell
            cell.collectionView.dataSource = self
            cell.collectionView.reloadData()
        }
    }
}

// MARK: - Collection View

extension ArtistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.albums.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        cell.setImage(url: viewModel.albums[indexPath.item].artworkUrl100)
        cell.titleLabel.text = viewModel.albums[indexPath.item].collectionName
        return cell
    }
}


// MARK: - Song Table View Cell Delegate

extension ArtistViewController: SongTableViewCellDelegate {
    func songTableViewCell(_ cell: SongTableViewCell, didPressButton downloadButton: DownloadButton) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
       
        let state = downloadService.state(of: viewModel.songs[indexPath.row].song)
        
        switch state {
        case .done:
            break
        case .loading(_):
            cell.downloadButton.loadingState = .paused
            downloadService.pause(song: viewModel.songs[indexPath.row].song)
        case .notStarted:
            cell.downloadButton.loadingState = .inProgress
            cell.downloadButton.progress = 0
            downloadService.start(song: viewModel.songs[indexPath.row].song)
        case .paused(_):
            cell.downloadButton.loadingState = .inProgress
            downloadService.resume(song: viewModel.songs[indexPath.row].song)
        }
        
    }
}

extension ArtistViewController: DownloadServiceDelegate {
    func downloadService(_ downloadService: DownloadService, didUpdateSong song: Song, withProgress progress: Double) {
        DispatchQueue.main.async {
            guard let row = self.viewModel.songs.firstIndex(where: { $0.song == song }) else {
                return
            }
            let indexPath = IndexPath(row: row, section: 1)
            self.viewModel.songs[indexPath.row].loadingState = .loading(progress: progress)
            if let cell = self.tableView.cellForRow(at: indexPath) as? SongTableViewCell {
                cell.downloadButton.progress = CGFloat(progress)
            }
        }
    }
    
    func downloadService(_ downloadService: DownloadService, didFinishDownloadingSong song: Song, to location: URL) {
        
        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(location.lastPathComponent)
        
        try? FileManager.default.removeItem(at: destinationURL)
        
        try! FileManager.default.copyItem(at: location, to: destinationURL)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let row = self.viewModel.songs.firstIndex(where: { $0.song == song }) else {
                return
            }
            let indexPath = IndexPath(row: row, section: 1)
            self.viewModel.songs[indexPath.row].loadingState = .done
            self.viewModel.songs[indexPath.row].fileURL = destinationURL
            if let cell = self.tableView.cellForRow(at: indexPath) as? SongTableViewCell {
                cell.downloadButton.progress = 100
                cell.downloadButton.loadingState = .done
            }
        }
    }
}
