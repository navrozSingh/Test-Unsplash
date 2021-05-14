//
//  ImagesloadingModal.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import UIKit
import Combine

class ImagesloadingModal: ObservableObject {
  
    var store = [URL: UIImage]()
    var downloadingTasks = [URL: IndexPath]()
    
    @Published var refreshIndex: IndexPath?
    
    private var cancellable = Set<AnyCancellable>()
    private lazy var queue: OperationQueue = {
        let que = OperationQueue()
        que.maxConcurrentOperationCount = 1
        return que
    }()
    
    func downloadImage(for url: URL, indexPath: IndexPath) {
        guard precondtions(for: url)
        else {
            return
        }
        queue.addOperation(operation(for: url, indexPath: indexPath))
    }
    
    func imageFromStore(for url: URL) -> UIImage? {
        guard let image = store[url]
        else {
            return nil
        }
        return image
    }

    private func precondtions(for url: URL) -> Bool {
        guard
            imageFromStore(for: url) == nil,
            downloadingTasks[url] == nil else {
            return false // Task in que or downloaded
        }
        return true
    }
    
    private func operation(for url: URL, indexPath: IndexPath) -> Operation {
        return BlockOperation(block: {
            self.downloadingTasks[url] = indexPath
            ImageCellRouter(url).fetch()
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure(let error):
                        print("Unable to fetch image", error)
                        break
                    case .finished:
                        print("Image fetched ")
                    }
                }, receiveValue: { [weak self] (res) in
                    guard let self = self,
                          let refreshIndex = self.downloadingTasks[res.0]
                    else {
                        return
                    }
                    self.store[res.0] = res.1
                    self.refreshIndex = refreshIndex
                    self.downloadingTasks.removeValue(forKey: res.0)
                }).store(in: &self.cancellable)
        })
    }
    
}
