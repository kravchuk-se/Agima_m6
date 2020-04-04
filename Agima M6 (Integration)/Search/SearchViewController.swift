//
//  SearchViewController.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 13.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ svc: SearchViewController, didSelectArtist artist: Artist)
    func searchViewControllerWillBeginScroll(_ svc: SearchViewController)
}

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!
    private var stateLabel: UILabel!
    
    weak var delegate: SearchViewControllerDelegate?
    
    private let viewModel = InfiniteList<Artist>(musicProvider: MusicAPI())
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFooter()
        setupTableView()
        
        viewModel.loadingInProgress
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        viewModel.state
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: stateLabel.rx.text)
            .disposed(by: bag)
    }
    
    private func setupFooter() {
        
        let padding: CGFloat = 8
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.sizeToFit()
        activityIndicator.hidesWhenStopped = true
        
        stateLabel = UILabel()
        stateLabel.text = "Default"
        stateLabel.textColor = .tertiaryLabel
        stateLabel.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, stateLabel])
        stackView.spacing = padding
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.frame = CGRect(x: 0, y: 0, width: 0, height: activityIndicator.bounds.height + stateLabel.bounds.height + padding)
        
        tableView.tableFooterView = stackView
    }
    
    private func setupTableView() {
        tableView.delegate = self
        
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "ArtistCell", cellType: UITableViewCell.self)) { index, artist, cell in
            cell.textLabel?.text = artist.name
            cell.detailTextLabel?.text = artist.primaryGenreName
        }.disposed(by: bag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Show Artist":
            let vc = segue.destination as! ArtistViewController
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            vc.viewModel = ArtistViewModel(artist: viewModel.items.value[indexPath.row])
        default:
            break
        }
    }
    
    func search(for searchTerm: SearchTerm) {
        if searchTerm.isEmpty {
            viewModel.reset()
        } else {
            viewModel.fetch(endpoint: .searchByName(searchTerm))
        }
    }
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.items.value.count - 1 {
            viewModel.fetchNextPortion()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchViewController(self, didSelectArtist: viewModel.items.value[indexPath.row])
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.searchViewControllerWillBeginScroll(self)
    }
}
