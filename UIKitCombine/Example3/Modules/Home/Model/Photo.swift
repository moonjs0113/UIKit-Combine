//
//  Photo.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/07.
//

import Foundation

// MARK: - Viewport
struct Viewport: Codable {
    let northeast, southwest: Location
}

struct Photo: Codable {
    let height: Int
    let htmlAttributions: [String]
    let photoReference: String
    let width: Int

    enum CodingKeys: String, CodingKey {
        case height, width
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
    }
}
