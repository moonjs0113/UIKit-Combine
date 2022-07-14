//
//  ImageAndLabelCollectionCellViewModel.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import Foundation

class ImageAndLabelCollectionCellViewModel {
    
    private var dataModel: ImageAndLabelCollectionCellModel!
    
    // Output
    @Published private(set) var imageURL: String?
    @Published private(set) var text: String?
    @Published private(set) var assetName: String?
    
    init(dataModel: ImageAndLabelCollectionCellModel) {
        self.dataModel = dataModel
        configureOutput()
    }
    
    private func configureOutput() {
        imageURL = dataModel.imageUrl
        text = dataModel.name
        assetName = dataModel.iconAssetName
    }
    
}
