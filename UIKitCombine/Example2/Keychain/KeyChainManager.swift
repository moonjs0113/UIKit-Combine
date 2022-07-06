//
//  KeyChainManager.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

class KeyChainManager: KeyChainManagerProtocol {
    // The keychain instance
    private let keychain: KeyChainProtocol
    
    // The initializer that introduces the keychain instance
    init(_ keychain: KeyChainProtocol) {
        self.keychain = keychain
    }
    
    @discardableResult func save(key: String, data: Data) -> OSStatus {
        let query = createSaveQuery(key: key, data: data)
        return keychain.add(query)
    }
    
    func load(key: String) -> Data? {
        let query = createSearchQuery(key: key)
        return keychain.search(query)
    }
    
    func delete(key: String, data: Data) throws -> OSStatus? {
        let query = createSaveQuery(key: key, data: Data.init())
        return keychain.delete(query)
    }
    
    func delete(key: String) throws -> OSStatus {
        if let data = load(key: key) {
            let query = createSaveQuery(key: key, data: data)
            return keychain.delete(query)
        }
        throw KeyChainError.itemMissing
    }
    
    // Build the query to be used in Saving Data
    func createSaveQuery(key: String, data: Data) -> [String: Any] {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ]
            as [String : Any]
        return query
    }
    
    // Build the query to be used in Loading Data
    func createSearchQuery(key: String) -> [String: Any] {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ]
            as [String : Any]
        return query
    }
}
