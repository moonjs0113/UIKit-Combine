//
//  PlaceListViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import Combine
import Foundation

class PlaceListViewModel {
    private var subscriptions = Set<AnyCancellable>()
    
    var numberOfRows = 0
    var title = ""
    
    private let placeType: PlaceType
    private var dataSource = [PlaceTableCellViewModel]()
    
    // Event
    var placeSelected: AnyPublisher<NearbyPlace, Never> {
        placeSelectedSubject.eraseToAnyPublisher()
    }
    
    private var placeSelectedSubject = PassthroughSubject<NearbyPlace, Never>()
    
    init(allPlaces: [NearbyPlace], placeType: PlaceType) {
        self.placeType = placeType
        dataSource = allPlaces.map {
            return PlaceTableCellViewModel(place: $0)
        }
        configureoutput()
    }
    
    private func configureoutput() {
        title = placeType.displayText
        numberOfRows = dataSource.count
    }
    
    func cellViewModel(indexPath: IndexPath) -> PlaceTableCellViewModel {
        let cellViewModel = dataSource[indexPath.row]
        let placeSelectedCallback: (NearbyPlace) -> Void = { [weak self] place in
            self?.placeSelectedSubject.send(place)
        }
        
        cellViewModel.placeSelected
            .sink(receiveValue: placeSelectedCallback)
            .store(in: &subscriptions)
        return cellViewModel
    }
}
