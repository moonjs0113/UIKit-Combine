//
//  PlacesTableCollectionCellViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import Foundation
import Combine

class PlacesTableCollectionCellVM: TableCollectionCellRepresentable {
    var numberOfItems: Int = 0
    var title: String = ""
    private var dataModel: PlacesTableCollectionCellModel!
    private var dataSource: [ImageAndLabelCollectionCellViewModel] = [ImageAndLabelCollectionCellViewModel]()
    
    var cellSelected: AnyPublisher<IndexPath, Never> {
        cellSelctedSubject.eraseToAnyPublisher()
    }
    private let cellSelctedSubject = PassthroughSubject<IndexPath, Never>()
    
    init(dataModel: PlacesTableCollectionCellModel) {
        self.dataModel = dataModel
        prepareCollectionDataSource()
        configureOutput()
    }
    
    private func configureOutput() {
        title = dataModel.title
        numberOfItems = dataSource.count
    }
    
    private func prepareCollectionDataSource() {
        if dataModel.places.count == 0 { return }
        let totalCount =  dataModel.places.count >= 3 ? 3 : dataModel.places.count
        for i in 0..<totalCount {
            let place = dataModel.places[i]
            let imageAndLabelDm = ImageAndLabelCollectionCellModel(name: place.name, imageUrl: place.imageURL, iconAssetName: nil)
            dataSource.append(ImageAndLabelCollectionCellViewModel(dataModel: imageAndLabelDm))
        }
    }
    
    func viewModelForCell(indexPath: IndexPath) -> ImageAndLabelCollectionCellViewModel {
        return dataSource[indexPath.row]
    }
    
    func cellSelected(indexPath: IndexPath) {
        cellSelctedSubject.send(indexPath)
    }
    
}

