//
//  PhotosViewModal.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation
import Combine

class PhotosViewModal: ObservableObject {
    
    let router: EndPointConfiguration
    private var cancellable: AnyCancellable?
    @Published var items = photos()
    
    init(route: EndPointConfiguration) {
        self.router = route
        callPhotosAPI()
    }
    
    fileprivate func callPhotosAPI() {
        cancellable = fetch()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print("photos API finished with error", error)
                    break
                case .finished:
                    print("photos API finished")
                }
            }, receiveValue: { [weak self] (photos) in
                self?.items = photos
            })
    }
    
    func fetch() -> AnyPublisher<photos, Error> {
        return router.callAPI()
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
