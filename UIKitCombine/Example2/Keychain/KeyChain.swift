//
//  KeyChain.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

class KeyChain: KeyChainProtocol {
    // Add data to the KeyChain, making sure that the entry does not already exist
    func add(_ query: [String : Any]) -> OSStatus {
        _ = delete(query)
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    // Fatch data from the KeyChain
    func search(_ query: [String : Any]) -> Data? {
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            return dataTypeRef as! Data?
        } else { return nil }
    }
    
    // Remove data from the Keychain
    func delete(_ query: [String : Any]) -> OSStatus {
        return SecItemDelete(query as CFDictionary)
    }
}
