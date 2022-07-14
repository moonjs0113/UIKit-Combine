//
//  PaginationCellViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import Combine

class PaginationCellViewModel {
    private var subscriptions = Set<AnyCancellable>()
    
    // Output
    var numberOfPages = 0
    var title = ""
    
    // Datasource
    private var dataSource = [NearbyPlace]()
    
    // Events
    var placeSelected: AnyPublisher<NearbyPlace, Never> {
        placeSelectedSubject.eraseToAnyPublisher()
    }
    
    private let placeSelectedSubject = PassthroughSubject<NearbyPlace, Never>()
    
    init(data: [NearbyPlace]) {
        dataSource = data
        configureOutput()
    }
    
    private func configureOutput() {
        numberOfPages = dataSource.count
        title = "Hot picks only for you"
    }
    
    func viewModelForPlaceView(position: Int) -> PlaceViewModel {
        let place = dataSource[position]
        let placeViewVM = PlaceViewModel(place: place)
        
        placeViewVM.placesViewSelected
            .sink { [weak self] in
            self?.placeSelectedSubject.send(place)
        }
        .store(in: &subscriptions)
        
        return placeViewVM
    }
    
}
