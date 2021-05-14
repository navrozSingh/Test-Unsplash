//
//  Router.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation
import Combine
class AlbumsRouter: EndPointConfiguration {
    
    var path: String {
        "/albums"
    }
    
    var httpMethod: HTTPMethod {
        .get
    }
    
}

class PhotosRouter: EndPointConfiguration {
    private let selectedAlbum: Album
    init(album: Album) {
        self.selectedAlbum = album
    }
    
    var path: String {
        "/albums/" + String(selectedAlbum.id) + "/photos"
    }
    
    var httpMethod: HTTPMethod {
        .get
    }
    
}

class ImageCellRouter: ObservableObject, EndPointConfigurationForImage {
    var url: URL
    @Published var items: ImageResposne?
    
    init(_ url: URL) {
        self.url = url
    }
    
    func fetch() -> AnyPublisher<ImageResposne, Error> {
        return self.callAPI()
            .eraseToAnyPublisher()
    }
}
