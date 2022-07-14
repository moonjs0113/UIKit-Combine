//
//  HomeViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/15.
//

import Foundation

/// Enum to distinguish different home cell types
enum HomeTableCellType {
    case pagingCell(model: PaginationCellViewModel)
    case categoriesCell(model: TableCollectionCellRepresentable)
    case placesCell(model: TableCollectionCellRepresentable)
}
