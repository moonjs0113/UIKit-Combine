//
//  Geometry.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/07.
//

import Foundation

struct Geometry: Codable {
    let location: Location
    let viewport: Viewport
}

// MARK: - Location
struct Location: Codable {
    let lat, lng: Double
}
