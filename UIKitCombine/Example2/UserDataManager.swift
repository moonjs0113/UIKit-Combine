//
//  UserDataManager.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

class UserDataManager: UserDataManagerProtocol {
    private let keychain: KeyChainManagerProtocol
    
    init(keychain: KeyChainManagerProtocol = KeyChainManager(KeyChain())) {
        self.keychain = keychain
    }
    
    func deleteToken() {
        _ = try? keychain.delete(key: KeyChainKeys.accessToken)
    }
    
    var token: String? {
        get {
            if let receivedData = keychain.load(key: KeyChainKeys.accessToken) {
                let accessTokenData = String(decoding: receivedData, as: UTF8.self)
                return accessTokenData
            }
            return nil
        }
        
        set {
            guard let newValue = newValue else { return }
            if let accessTokenData = newValue.data(using: .utf8) {
                self.keychain.save(key: KeyChainKeys.accessToken, data: accessTokenData)
            }
        }
    }
}
