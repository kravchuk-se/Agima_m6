//
//  InfinityListViewController.swift
//  Agima M6 (Integration)
//
//  Created by Kravchuk Sergey on 24.03.2020.
//  Copyright © 2020 Kravchuk Sergey. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InfinityListViewController<T: Loadable>: UIViewController, UITableViewDelegate {
    
    private var tableView: UITableView!
    
    var infinityList: InfinityList<T>
    var endpoint: T.EndpointType
    
    private let cellIdentifier = "Cell"
    private let bag = DisposeBag()
    
    init(list: InfinityList<T>, endpoint: T.EndpointType) {
        self.infinityList = list
        self.endpoint = endpoint

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cellConfiguration: ((T, UITableViewCell)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        infinityList.items.bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: UITableViewCell.self)) { [weak self] index, item, cell in
            self?.cellConfiguration?(item, cell)
        }.disposed(by: bag)
        
        infinityList.fetch(endpoint: endpoint)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == infinityList.items.value.count - 1 {
            infinityList.fetchNextPortion()
        }
    }

}
