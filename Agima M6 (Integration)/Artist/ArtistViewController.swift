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

class ArtistViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ArtistViewModel!
    
    private let bag = DisposeBag()
    
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
    }
    
    private func showAllSongs() {
        let vc = InfinityListViewController(
                list: InfinityList<Song>(musicProvider: viewModel.musicProvider),
                endpoint: .searchByArtist(artist: viewModel.artist))
        vc.title = "All songs"
        show(vc, sender: nil)
    }
    
    private func showAllAlbums() {
        let vc = InfinityListViewController(
            list: InfinityList<Album>(musicProvider: viewModel.musicProvider),
            endpoint: .searchByArtist(artist: viewModel.artist))
        vc.title = "All albums"
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
            let song = viewModel.songs[indexPath.row]
            cell.textLabel?.text = song.trackName
            cell.detailTextLabel?.text = song.artistName
            return cell
        default:
            return UITableViewCell()
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
