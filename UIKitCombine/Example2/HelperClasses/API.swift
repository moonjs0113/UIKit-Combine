//
//  API.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import Foundation

// https://reqres.in/api
// https://medium.com/swlh/building-urls-in-swift-51f21240c537

enum API {
    case login
    case register
    
    var url: URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "reqres.in"
        component.path = path
        return component.url
    }
}

extension API {
    fileprivate var path: String {
        switch self {
        case .login:
            return "/api/login"
        case .register:
            return "api/register"
        }
    }
}
