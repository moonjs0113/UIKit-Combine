//
//  HomeViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/15.
//

import Foundation
import Combine

class HomeViewModel {
    private var subscriptions = Set<AnyCancellable>()
    
    /// Data source for the home page table view.
    private var tableDataSource: [HomeTableCellType] = [HomeTableCellType]()
    private var allPlaces = [NearbyPlace]()
    
    // MARK: Input
    private var loadData: AnyPublisher<Void, Never> = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
    
    // MARK: Output
    var numberOfRows: Int {
        tableDataSource.count
    }
    
    var placeChoosed: AnyPublisher<NearbyPlace, Never> {
        placeChoosedSubject.eraseToAnyPublisher()
    }
    
    var categoryChoosed: AnyPublisher<PlaceType, Never> {
        categoryChoosedSubject.eraseToAnyPublisher()
    }
    
    var reloadplaceList: AnyPublisher<Result<Void,NearbyAPIError>, Never> {
        reloadplaceListSubject.eraseToAnyPublisher()
    }
    
    private let placeChoosedSubject = PassthroughSubject<NearbyPlace, Never>()
    private let categoryChoosedSubject = PassthroughSubject<PlaceType, Never>()
    private let reloadplaceListSubject = PassthroughSubject<Result<Void,NearbyAPIError>, Never>()
    
    init() {
        
    }
    
    func attachViewEventListener(loadData: AnyPublisher<Void, Never>) {
        self.loadData = loadData
        self.loadData
            .setFailureType(to: NearbyAPIError.self)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.allPlaces.removeAll()
            })
            .flatMap { _ -> AnyPublisher<[NearbyPlace], NearbyAPIError> in
                let placeWebservice = PlaceWebService()
                return placeWebservice
                    .fetchAllPlaceList()
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.tableDataSource.removeAll()
            })
            .sink{ _ in
                
            } receiveValue: { [weak self] places in
                self?.allPlaces.append(contentsOf: places)
                self?.prepareTableDataSource()
                self?.reloadplaceListSubject.send(.success(()))
            }
            .store(in: &subscriptions)
    }
    
    /// Prepare the tableDataSource
    private func prepareTableDataSource() {
        tableDataSource.append(celltypeForPagingCell())
        tableDataSource.append(cellTypeForCategoriesCell())
        tableDataSource.append(contentsOf: cellTypeForPlaces())
    }
    
    /// Provides a pagination cell type for each place type.
    private func celltypeForPagingCell() -> HomeTableCellType {
        var places = [NearbyPlace]()
        for placeType in PlaceType.allCases {
            places.append(contentsOf: getTopPlace(placeType: placeType, topPlacesCount: 1))
        }
        let placeSelected: (NearbyPlace) -> () = { [weak self] place in
            self?.placeChoosedSubject.send(place)
        }
        
        let paginationCellViewModel = PaginationCellViewModel(data: places)
        paginationCellViewModel.placeSelected
            .sink(receiveValue: placeSelected)
            .store(in: &subscriptions)
        
        return HomeTableCellType.pagingCell(model: paginationCellViewModel)
    }
    
    /// Provides a placesCell type.
    private func cellTypeForCategoriesCell() -> HomeTableCellType {
        let categoryViewModel = CategoriesTableCollectionCellViewModel()
        
        categoryViewModel.cellSelected.sink { [weak self] indexPath in
            self?.categoryChoosedSubject.send(PlaceType.allCases[indexPath.row])
        }
        .store(in: &subscriptions)
        
        return HomeTableCellType.categoriesCell(model: categoryViewModel)
    }
    
    /// Provides a placesCell type.
    private func cellTypeForPlaces() -> [HomeTableCellType] {
        var cellTypes = [HomeTableCellType]()
        let allPlaceTypes = PlaceType.allCases
        for type in allPlaceTypes {
            let topPlaces = getTopPlace(placeType: type, topPlacesCount: 3)
            let placeCellViewModel = PlacesTableCollectionCellViewModel(
                dataModel: PlacesTableCollectionCellModel(places: topPlaces,
                                                          title: type.homeCellTitleText))
            placeCellViewModel.cellSelected.sink { [weak self] indexPath in
                self?.placeChoosedSubject.send(topPlaces[indexPath.item])
            }
            .store(in: &subscriptions)
            
            if topPlaces.count > 0 {
                cellTypes.append(HomeTableCellType.placesCell(model: placeCellViewModel))
            }
        }
        return cellTypes
    }
    
    /// Provides the view with appropriate cell type corresponding to an index.
    func cellType(forIndex indexPath: IndexPath) -> HomeTableCellType {
        return tableDataSource[indexPath.row]
    }
    
    func getTopPlace(placeType: PlaceType, topPlacesCount: Int) -> [NearbyPlace] {
        let places = allPlaces.filter {
            $0.type == placeType
        }
        return Array(places.prefix(topPlacesCount))
    }
    
    func getPlaceListViewModel(placeType: PlaceType) -> PlaceListViewModel {
        let places = allPlaces.filter {
            $0.type == placeType
        }
        return PlaceListViewModel(allPlaces: places, placeType: placeType)
    }
}

