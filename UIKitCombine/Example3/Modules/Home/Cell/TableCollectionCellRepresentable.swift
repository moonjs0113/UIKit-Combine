//
//  TableCollectionCellRepresentable.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/15.
//

import Foundation
import Combine

protocol TableCollectionCellRepresentable {
    // Output
    var title: String { get }
    var numberOfItems: Int { get }
    func viewModelForCell(indexPath: IndexPath) -> ImageAndLabelCollectionCellViewModel
    var cellSelected: AnyPublisher<IndexPath, Never> { get }
    
    //Input
    func cellSelected(indexPath: IndexPath)
 }
