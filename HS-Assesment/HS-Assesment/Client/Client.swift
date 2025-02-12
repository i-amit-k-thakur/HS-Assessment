//
//  Client.swift
//  HS-Assesment
//
//  Created by Amit Thakur on 11/02/2025.
//

import Foundation

enum ClientError: Error {
    case noError(errorMessage: ErrorMessages)
    case dataError(errorMessage: ErrorMessages)            // Indicates network error
    case clientError(errorMessage: ErrorMessages)    // Indicates something was wrong with the request
    
    static func == (lhs: ClientError, rhs: ClientError) -> Bool {
        var returnValue = false
        if (type(of: lhs) == type(of: rhs)) {
            if let first = lhs as NSError?, let second = rhs as NSError? {
                returnValue =  (first.domain == second.domain) && (first.code == second.code)
            }
        }
        return returnValue
    }
    
    var displayMessage: String {
        switch self {
        case .noError(errorMessage: let errorMessage):
            return errorMessage.rawValue
        case .dataError(errorMessage: let errorMessage):
            return errorMessage.rawValue
        case .clientError(errorMessage: let errorMessage):
            return errorMessage.rawValue
        }
    }
}

enum ErrorMessages: String {
    case noError = ""
    case dataProcessingIssueMessage = "Uh oh! We were not able to process the data. Please try again."
    case configurationIssueMessage = "Looks like you are looking in the wrong direction. To fix this, try upgrading your app."
    case serverIssueMessage = "Tonight's gonna be a cloudy night. Check back later."
    case noDataIssueMessage = "Welcome to the dark side of the moon."
}

typealias ClientResult = (Result<Results, ClientError>) -> Void
typealias ClientResponseResult = (Result<String, ClientError>) -> Void

protocol ClientProtocol {
    var service: HTTPClientProtocol { get set }
    mutating func fetchAssociations(with completionHandler: @escaping ClientResult)
    mutating func sendValidatedResult(response:ValidatedResponse, with completionHandler: @escaping ClientResponseResult)

}

struct Client: ClientProtocol {

    var service: HTTPClientProtocol
    
    fileprivate var request: URLRequest? {
        var urlComponents = URLComponents(string: "https://candidate.hubteam.com")
        urlComponents?.path += "/candidateTest/v3/problem/dataset"
        urlComponents?.queryItems = [URLQueryItem(name: "userKey", value: "006dc715b09138fc8342d158faae")]
        
        guard let url = urlComponents?.url else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    mutating func fetchAssociations(with completionHandler: @escaping ClientResult) {
        
        guard let urlRequest = request else {
            completionHandler(.failure(.dataError(errorMessage: .dataProcessingIssueMessage)))
            return
        }
        
        service.perform(request: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let results: Results = try JSONDecoder().decode(Results.self, from: data) //{
                    completionHandler(.success(results))
//                    } else {
//                        completionHandler(.failure(.dataError(errorMessage: .dataProcessingIssueMessage)))
//                    }
                } catch let jsonError as NSError {
                    print("JSON decode failed: \(jsonError.debugDescription)")
                    completionHandler(.failure(.dataError(errorMessage: .dataProcessingIssueMessage)))
                }
                break
                
            case .failure(let error):
                switch error {
                case .networkError:
                    completionHandler(.failure(.clientError(errorMessage: .dataProcessingIssueMessage)))
                    break
                    
                case .clientError:
                    completionHandler(.failure(.clientError(errorMessage: .configurationIssueMessage)))
                    break
                    
                case .serverError:
                    completionHandler(.failure(.clientError(errorMessage: .serverIssueMessage)))
                    break
                    
                case .noData:
                    completionHandler(.failure(.dataError(errorMessage: .noDataIssueMessage)))
                    break
                }
            }
        }
    }
    
    fileprivate var postRequest: URLRequest? {
        var urlComponents = URLComponents(string: "https://candidate.hubteam.com")
        urlComponents?.path += "/candidateTest/v3/problem/result"
        urlComponents?.queryItems = [URLQueryItem(name: "userKey", value: "006dc715b09138fc8342d158faae")]
        
        guard let url = urlComponents?.url else {
            return nil
        }
        
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
    
    mutating func sendValidatedResult(response:ValidatedResponse, with completionHandler: @escaping ClientResponseResult) {
        
        guard var urlRequest = postRequest else {
            completionHandler(.failure(.dataError(errorMessage: .dataProcessingIssueMessage)))
            return
        }
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(response)
            
//            print("****************************************************")
//            let json = String(data: jsonData, encoding: String.Encoding.utf8)
//            print(json?.description ?? "")
//            print("****************************************************")

            urlRequest.httpBody = jsonData
        } catch let jsonError as NSError {
            print("JSON encoding failed: \(jsonError.debugDescription)")
        }
        
        
        service.perform(request: urlRequest) { result in
            switch result {
            case .success(let data):
                
//                print("****************************************************")
//                let json = String(data: data, encoding: String.Encoding.utf8)
//                print(json?.description ?? "")
//                print("****************************************************")

                completionHandler(.success("Yay!"))
                break
                
            case .failure(let error):
                switch error {
                case .networkError:
                    completionHandler(.failure(.clientError(errorMessage: .dataProcessingIssueMessage)))
                    break
                    
                case .clientError:
                    completionHandler(.failure(.clientError(errorMessage: .configurationIssueMessage)))
                    break
                    
                case .serverError:
                    completionHandler(.failure(.clientError(errorMessage: .serverIssueMessage)))
                    break
                    
                case .noData:
                    completionHandler(.failure(.dataError(errorMessage: .noDataIssueMessage)))
                    break
                }
            }
        }
    }
}
