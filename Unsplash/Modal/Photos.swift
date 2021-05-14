//
//  Photos.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation

// MARK: - Photos
struct Photos: Codable {
    let albumID, id: Int
    let title: String
    let url, thumbnailURL: String
    
    enum CodingKeys: String, CodingKey {
        case albumID = "albumId"
        case id, title, url
        case thumbnailURL = "thumbnailUrl"
    }
}
extension Photos {
    func photoURL() -> URL {
        guard let url = URL(string: url) else {
            preconditionFailure("PhotoURL is not available")
        }
        return url
    }
}
typealias photos = [Photos]
