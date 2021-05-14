//
//  ImagesVC.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation
import UIKit
import Combine

final class PhotosVC: UIViewController {
    
    let viewModal: PhotosViewModal
    let imageModel = ImagesloadingModal()
    private var cancellable = Set<AnyCancellable>()

    //MARK: Initialization
    init?(coder: NSCoder, viewModal: PhotosViewModal) {
        self.viewModal = viewModal
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a viewModal.")
    }
    //UI
    let photosTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        setupUI()
        bindVM()
    }
    
    func setupUI() {
        self.view = photosTableView
        photosTableView.dataSource = self
        photosTableView.delegate = self
    }
    
    func bindVM() {
        viewModal.$items.sink { [weak self] photos in
            self?.latestPhoto = photos
        }.store(in: &cancellable)
        
        imageModel.$refreshIndex.sink { [weak self] index in
            guard let index = index,
                  let self = self
            else { return }
            DispatchQueue.main.async {
                self.photosTableView.reloadRows(at: [index], with: .middle)
            }
        }.store(in: &cancellable)
    }
    
    var latestPhoto = photos() {
        didSet {
            photosTableView.reloadData()
        }
    }

}
extension PhotosVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        latestPhoto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as? ImageCell
        else {
            fatalError("Cell not configured")
        }
        let url = latestPhoto[indexPath.row].photoURL()
        imageModel.downloadImage(for: url, indexPath: indexPath)
        cell.cellImageView.image = imageModel.imageFromStore(for: url)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = imageModel.imageFromStore(for: latestPhoto[indexPath.row].photoURL())
        else {
            return 44
        }
        return calculateImageHeight(image)
    }
    
    private func calculateImageHeight(_ image : UIImage) -> CGFloat {
        let aspectRatio = image.size.height / image.size.width
        return self.view.frame.width * aspectRatio
    }
}
