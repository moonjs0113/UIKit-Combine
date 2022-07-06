//
//  KeyChainManagerProtocol.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

public protocol KeyChainManagerProtocol {
    @discardableResult func save(key: String, data: Data) -> OSStatus
    func load(key: String) -> Data?
    func delete(key: String, data: Data) throws -> OSStatus?
    func delete(key: String) throws -> OSStatus
}
