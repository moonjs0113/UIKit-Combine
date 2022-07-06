//
//  Data+Extension.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

// MARK: - Encode and decode Swift's number types as Data Objects
extension Data {
    init<T>(from value: T) {
        var value = value
        var myData = Data()
        withUnsafePointer(to: &value) { ptr in
            myData = Data(buffer: UnsafeBufferPointer(start: ptr, count: 1))
        }
        self.init(myData)
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes {
            $0.load(as: T.self)
        }
    }
}
