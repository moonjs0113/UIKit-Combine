//
//  PlaceType.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/07.
//

import Foundation

enum PlaceType: String, CaseIterable {
    case restaurant = "restaurant"
    case atm = "atm"
    case nightClub = "night_club"
    case cafe = "cafe"
    
    var iconName: String {
        switch self {
        case .restaurant:
            return "restaurant"
        case .atm:
            return "atm"
        case .nightClub:
            return "nightclub"
        case .cafe:
            return "cafe"
        }
    }
    
    var displayText: String {
        switch self {
        case .restaurant:
            return "Restaurant"
        case .atm:
            return "ATM"
        case .nightClub:
            return "Night Club"
        case .cafe:
            return "Cafe"
        }
    }
    
    var homeCellTitleText: String {
        switch self {
        case .restaurant:
            return "Top Restaurants nearby"
        case .atm:
            return "Closest ATMs nearby"
        case .nightClub:
            return "Top Nightclubs nearby"
        case .cafe:
            return "Top Cafes nearby"
        }
    }
    
}
