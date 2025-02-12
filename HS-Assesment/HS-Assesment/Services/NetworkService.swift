//
//  NetworkService.swift
//  HS-Assesment
//
//  Created by Amit Thakur on 11/02/2025.
//

import Foundation

enum HTTPClientError: Error, Equatable {
    case networkError            // Indicates network error
    case clientError    // Indicates something was wrong with the request
    case serverError    // Indicates something was wrong at the server.
    case noData                         // Indicates no data was returned
    
    static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
        var returnValue = false
        if (type(of: lhs) == type(of: rhs)) {
            if let first = lhs as NSError?, let second = rhs as NSError? {
                returnValue = (first.domain == second.domain) && (first.code == second.code)
            }
        }
        return returnValue
    }
}

typealias NetworkServiceResult = (Result<Data, HTTPClientError>) -> Void

protocol HTTPClientProtocol {
    var urlSession: URLSession { get }
    func perform(request: URLRequest, with completionHandler: @escaping NetworkServiceResult)
}

class NetworkService: HTTPClientProtocol {
    
    var urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
        
    func perform(request: URLRequest, with completionHandler: @escaping NetworkServiceResult) {

        self.urlSession.dataTask(with: request) { data, response, error in

            
            /// Error
            if let _ = error {
                completionHandler(.failure(.networkError))
                return
            }
            
            /// HTTP URL Response
            if let response = response as? HTTPURLResponse, !(200...399).contains(response.statusCode) {
                
                let json = String(data: data!, encoding: String.Encoding.utf8)
                print(json)
                
                switch response.statusCode {
                case 400...499:
                    
                    completionHandler(.failure(.clientError))
                    return
                default:
                    completionHandler(.failure(.serverError))
                    return
               }
            }
            
            /// Success with a guard
            guard let data = data else {
                completionHandler(.failure(.noData))
                return
            }
            
            completionHandler(.success(data))
            
        }.resume()

    }

}
