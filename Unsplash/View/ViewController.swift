//
//  ViewController.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private struct Constants {
        static let title = "All Albums"
        static let cellID = "albumCell"
        static let searchPlaceholder = "Search Albums"
    }
    //Model
    private let albumsModel = AlbumsModel()
    private var cancellable: AnyCancellable?
    
    //UI
    private let searchController = UISearchController(searchResultsController: nil)

    lazy var albumTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "albumCell")
        return tableView
    }()
    
    var latestAlbums = albums() {
        didSet {
            albumTableView.reloadData()
        }
    }
    
    var filteredAlbums = albums() {
        didSet {
            albumTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        uiSetup()
        bindVM()
    }
    
    private func uiSetup() {
        navigationSetup()
        self.view = albumTableView
    }
    private func navigationSetup() {
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = Constants.title
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Constants.searchPlaceholder
        navigationItem.searchController = searchController
        definesPresentationContext = true

    }
    
    private func bindVM() {
        cancellable = albumsModel.$items.sink { [weak self] albums in
            self?.latestAlbums = albums
        }
    }
    
}
extension ViewController: UISearchResultsUpdating {
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard
            isSearchBarEmpty == false,
            let searchText = searchController.searchBar.text
        else {
            return
        }
        filteredAlbums = albumsModel.filterAlbums(for: searchText)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredAlbums.count : latestAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Constants.cellID)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        let modal = isFiltering ? filteredAlbums[indexPath.row] : latestAlbums[indexPath.row]
        cell.textLabel?.text = modal.title
        cell.detailTextLabel?.text = modal.collaboratedDetails()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAlbum = isFiltering ? filteredAlbums[indexPath.row] : latestAlbums[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "PhotosVC", creator: { coder in
            let route = PhotosRouter(album: selectedAlbum)
            return PhotosVC(coder: coder, viewModal: PhotosViewModal(route: route))
        }) else {
            fatalError("Failed to load EditUserViewController from storyboard.")
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
