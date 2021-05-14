//
//  ViewController.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    //Model
    private let albumsModel = AlbumsModel()
    private var cancellable: AnyCancellable?
    
    //UI
    let albumTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "albumCell")
        return tableView
    }()
    
    var latestAlbums = albums() {
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
        self.view = albumTableView
        albumTableView.dataSource = self
        albumTableView.delegate = self
    }
    
    private func bindVM() {
        cancellable = albumsModel.$items.sink { [weak self] albums in
            self?.latestAlbums = albums
        }
    }
    
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        latestAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "albumCell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = latestAlbums[indexPath.row].title
        cell.detailTextLabel?.text = latestAlbums[indexPath.row].collaboratedDetails()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAlbum = latestAlbums[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "PhotosVC", creator: { coder in
            let route = PhotosRouter(album: selectedAlbum)
            return PhotosVC(coder: coder, viewModal: PhotosViewModal(route: route))
        }) else {
            fatalError("Failed to load EditUserViewController from storyboard.")
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
