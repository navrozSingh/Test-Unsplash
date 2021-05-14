//
//  Albums.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation
import Combine
// MARK: - Albums
typealias albums = [Album]
struct Album: Codable {
    let userID, id: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title
    }
}
extension Album {
    func collaboratedDetails() -> String {
        """
        User Id = \(userID)
        Album Id = \(id)
        """
    }
}


