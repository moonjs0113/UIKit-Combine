//
//  Contents.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

var passwordLength = 0

enum RuntimeError: Error {
    case runtimeError(String)
}

enum KeyChainKeys: CaseIterable {
    static let accessToken = "access"
}

enum KeyChainOperations: String {
    case token
}
