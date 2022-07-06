//
//  HTTPManagerProtocol.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation
import Combine

protocol HTTPManagerProtocol {
    associatedtype aType
    var session: aType { get }
    init(session: aType)
    
    func post<T: Decodable>(url: URL, headers: [String: String], data: Data) -> AnyPublisher<T, Error>
}
