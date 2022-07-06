//
//  KeyChainProtocol.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

public protocol KeyChainProtocol {
    func add( _ query: [String: Any]) -> OSStatus
    func search( _ query: [String: Any]) -> Data?
    func delete( _ query: [String: Any]) -> OSStatus
}
