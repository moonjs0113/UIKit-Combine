//
//  CategoriesTableCollectionCellViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/15.
//

import Foundation
import Combine

class CategoriesTableCollectionCellViewModel: TableCollectionCellRepresentable {
    
    // Output
    var title: String = ""
    var numberOfItems: Int = 0
    
    // Events
    var cellSelected: AnyPublisher<IndexPath, Never> {
        categoriesCellSelectedSubject.eraseToAnyPublisher()
    }
    
    private var categoriesCellSelectedSubject = PassthroughSubject<IndexPath, Never>()
    
    private var dataSource: [ImageAndLabelCollectionCellViewModel] = [ImageAndLabelCollectionCellViewModel]()
    
    init() {
        prepareDataSource()
        configureOutput()
    }
    
    private func prepareDataSource() {
        for type in PlaceType.allCases {
            dataSource.append(
                ImageAndLabelCollectionCellViewModel(
                    dataModel: ImageAndLabelCollectionCellModel(name: type.displayText,
                                                                imageUrl: nil,
                                                                iconAssetName: type.iconName)
                )
            )
        }
    }
    
    private func configureOutput() {
        title = "Want to be more specific"
        numberOfItems = dataSource.count
    }
    
    func viewModelForCell(indexPath: IndexPath) -> ImageAndLabelCollectionCellViewModel {
       return dataSource[indexPath.item]
    }
    
    func cellSelected(indexPath: IndexPath) {
        categoriesCellSelectedSubject.send(indexPath)
    }
    
}
