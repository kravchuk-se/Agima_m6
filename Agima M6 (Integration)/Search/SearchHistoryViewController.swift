//
//  SearchHistoryViewController.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 30.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


typealias SearchTerm = String


class SearchHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchTerms: [SearchTerm] = []
    
    private let bag = DisposeBag()
    private weak var searchViewController: SearchViewController!
    private var selectedArtist: Artist?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        searchViewController = UIStoryboard.init(name: "Search", bundle: .main).instantiateInitialViewController() as? SearchViewController
        searchViewController.delegate = self
        let searchController = UISearchController(searchResultsController: searchViewController)
        navigationItem.searchController = searchController
        
        searchController.searchBar.rx.text
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .compactMap { $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] searchTerm in
                self?.performSearch(for: searchTerm)
            })
            .disposed(by: bag)
        
        loadHistory { terms in
            self.searchTerms = terms
            self.tableView.reloadData()
        }
        
    }
    
    var supportDirectory: URL {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }
    var historyFileURL: URL {
        let fileName = "searchHistory.json"
        return supportDirectory.appendingPathComponent(fileName)
    }
    private let fileAccessQueue = DispatchQueue(label: "com.kravchuk.fileAccess", qos: .userInitiated)
    func saveHistory() {
        fileAccessQueue.async { [searchTerms] in
            do {
                let data = try JSONEncoder().encode(searchTerms)
                try FileManager.default.createDirectory(at: self.supportDirectory, withIntermediateDirectories: true, attributes: nil)
                FileManager.default.createFile(atPath: self.historyFileURL.path, contents: nil, attributes: nil)
                try data.write(to: self.historyFileURL)
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(error: error)
                }
            }
        }
    }
    
    static let defaultTerms: [SearchTerm] = ["Lana", "Queen", "Billie"]
    func loadHistory(comlpetion: @escaping (([SearchTerm]) -> ())) {
        fileAccessQueue.async {
            if FileManager.default.fileExists(atPath: self.historyFileURL.path) {
                do {
                    let data = try Data(contentsOf: self.historyFileURL)
                    let terms = try JSONDecoder().decode([SearchTerm].self, from: data)
                    DispatchQueue.main.async {
                        comlpetion(terms)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(error: error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    comlpetion(SearchHistoryViewController.defaultTerms)
                }
            }
        }
    }
    
    func showAlert(error: Error) {
        let vc = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    func performSearch(for searchTerm: SearchTerm) {
        searchViewController.search(for: searchTerm)
    }
    
    fileprivate func didSelectArtist(_ artist: Artist) {
        selectedArtist = artist
        
        if let searchTerm = navigationItem.searchController?.searchBar.text {
            if !searchTerms.contains(searchTerm) {
                searchTerms.append(searchTerm)
                tableView.insertRows(at: [IndexPath(row: searchTerms.count - 1, section: 0)], with: .automatic)
                saveHistory()
            }
        }
        
        performSegue(withIdentifier: "Show Artist", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Show Artist":
            guard let artist = selectedArtist, let vc = segue.destination as? ArtistViewController else { return }
            vc.viewModel = ArtistViewModel(artist: artist)
        default:
            break
        }
    }
    
}

extension SearchHistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchTerms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTermCell", for: indexPath)
        cell.textLabel?.text = searchTerms[indexPath.row]
        return cell
    }
}
extension SearchHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationItem.searchController?.searchBar.text = searchTerms[indexPath.row]
        navigationItem.searchController?.searchBar.becomeFirstResponder()
        performSearch(for: searchTerms[indexPath.row])
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        searchTerms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveHistory()
    }
}


extension SearchHistoryViewController: SearchViewControllerDelegate {
    func searchViewController(_ svc: SearchViewController, didSelectArtist artist: Artist) {
        didSelectArtist(artist)
    }
}
