//
//  PlaceDetailViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import Foundation
import CoreLocation
import Combine
import MapKit

class PlaceDetailViewModel {
    // MARK: Published
    @Published private(set) var title = ""
    @Published private(set) var distance = ""
    @Published private(set) var isOpen = true
    @Published private(set) var placeImageUrl = ""
    @Published private(set) var location: CLLocation? = nil
    
    private let place: NearbyPlace
    
    init(place: NearbyPlace) {
        self.place = place
        self.configureOutput()
    }
    
    private func configureOutput() {
        title = place.name
        let openState = place.openStatus ?? false
        isOpen = openState
        location = place.location
        placeImageUrl = place.imageURL ?? ""
        
        let currentLocation = CLLocation(latitude: LocationManager.sharedManager.latitude,
                                         longitude: LocationManager.sharedManager.longitude)
        guard let distance = place.location?.distance(from: currentLocation) else {
            return
        }
        
        self.distance = String(format: "%.2f mi", distance/1609.344)
    }
}
