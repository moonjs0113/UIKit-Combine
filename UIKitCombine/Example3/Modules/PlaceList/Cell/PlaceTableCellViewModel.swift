//
//  PlaceTableCellViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import Foundation

import Combine

class PlaceTableCellViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private var place: NearbyPlace!
    
    var placeViewModel: PlaceViewModel!
    var placeSelected: AnyPublisher<NearbyPlace, Never> {
        placeSelectedSubject.eraseToAnyPublisher()
    }
    let placeSelectedSubject = PassthroughSubject<NearbyPlace, Never>()
    
    init(place: NearbyPlace) {
        self.place = place
        preparePlaceViewVM()
    }
    
    private func preparePlaceViewVM() {
        placeViewModel = PlaceViewModel(place: place)
        placeViewModel.placesViewSelected
            .sink { [weak self] in
            guard let self = self else { return }
                self.placeSelectedSubject.send(self.place)
        }
        .store(in: &subscriptions)
    }
}
