//
//  AlbumsModel.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation
import Combine

class AlbumsModel: ObservableObject {
    @Published var items = albums()
    private var currentAlbums = albums()
    private let router: EndPointConfiguration
    private var cancellable: AnyCancellable?
    
    init(route: EndPointConfiguration = AlbumsRouter()) {
        self.router = route
        callAlbumAPI()
    }
    
    fileprivate func callAlbumAPI() {
        cancellable = fetch()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print("Albums API finished with error", error)
                    break
                case .finished:
                    print("Albums API finished")
                }
            }, receiveValue: { [weak self] (albums) in
                self?.items = albums
                self?.currentAlbums = albums
            })
    }
    
    func filterAlbums(for searchText: String) -> albums {
        return currentAlbums.filter {
            return $0.title.lowercased().contains(searchText.lowercased())
        }

    }
    
    func fetch() -> AnyPublisher<albums, Error> {
        return router.callAPI()
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
}
