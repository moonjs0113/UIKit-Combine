//
//  HTTPManager.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation
import Combine

class HTTPManager<T: URLSessionProtocol> {
    // A URLProtocol instance that is replaced by the URLSession in production code
    
    let session: T
    
    required init(session: T) {
        self.session = session
    }
    
    public func post<T : Decodable>(url: URL, headers: [String : String], data: Data) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 2.0)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = data
        
        return session.response(for: request)
            .map {
                $0.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}
