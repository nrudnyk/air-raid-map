//
//  NetworkManager.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 23.04.2022.
//

import Foundation
import Combine
import Hyperconnectivity

class NetworkManager {
    
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badURLResponse(url: let url): return "[‼️] Bad response from URL: \(url)"
            case .unknown: return "[⚠️] Unknown error occured"
            }
        }
    }

    static func getNetworkState() -> AnyPublisher<Bool, Never> {
        Hyperconnectivity.Publisher()
            .map { $0.isConnected }
            .eraseToAnyPublisher()
    }

    static func download(request: URLRequest) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ try handleURLResponse(output: $0, url: request.url!) })
            .retry(3)
            .eraseToAnyPublisher()
    }
    
    static func download(url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ try handleURLResponse(output: $0, url: url) })
            .retry(3)
            .eraseToAnyPublisher()
    }
    
    static func download(request: URLRequest, completion: @escaping (Data) -> Void) {
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            guard let response = urlResponse as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300,
                  let data = data
            else {
                if let description = NetworkingError.badURLResponse(url: request.url!).errorDescription { print(description) }
                if let description = error?.localizedDescription { print(description) }
                return
            }
            
            completion(data)
        }.resume()
    }
    
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        return output.data
    }
    
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
