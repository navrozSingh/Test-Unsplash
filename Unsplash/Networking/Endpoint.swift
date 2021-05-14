//
//  Endpoint.swift
//  Unsplash
//
//  Created by Navroz on 15/05/21.
//

import Foundation
import UIKit
import Combine

public enum HTTPMethod : String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

struct Response<T> {
    let value: T
    let response: URLResponse
}

protocol EndPointConfiguration {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    func callAPI<T: Decodable>() -> AnyPublisher<Response<T>, Error>
}

extension EndPointConfiguration {
    func callAPI<T: Decodable>() -> AnyPublisher<Response<T>, Error> {
        var request = URLRequest(url: getURL())
        request.httpMethod = httpMethod.rawValue
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                guard
                    let httpResponse = result.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200
                else {
                    throw APIFailureCondition.invalidServerResponse
                }
                
                let decoder = JSONDecoder()
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func getURL()-> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "jsonplaceholder.typicode.com"
        components.path = path
        guard let url = components.url else {
            preconditionFailure("Invalid url")
        }
        return url
    }
}

enum APIFailureCondition: Error {
    case invalidServerResponse
}

protocol EndPointConfigurationForImage {
    typealias ImageResposne = (URL, UIImage)
    var url: URL { get }
    func callAPI() -> AnyPublisher<ImageResposne, Error>
}

extension EndPointConfigurationForImage {
    func callAPI() -> AnyPublisher<ImageResposne, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> ImageResposne in
                guard
                    let httpResponse = result.response as? HTTPURLResponse,
                    let forURL = httpResponse.url,
                    httpResponse.statusCode == 200,
                    let image = UIImage(data: result.data)
                else {
                    throw APIFailureCondition.invalidServerResponse
                }
                
                return (forURL, image)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
