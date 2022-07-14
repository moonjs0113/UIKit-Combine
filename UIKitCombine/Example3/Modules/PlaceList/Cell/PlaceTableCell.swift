//
//  PlaceTableCell.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import UIKit
import Combine

class PlaceTableCell: ReusableTableViewCell {
    @IBOutlet weak var placeView: PlaceView!
    
    var viewModel: PlaceTableCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func prepareCell(viewModel: PlaceTableCellViewModel) {
        self.viewModel = viewModel
        placeView.preparePlaceView(viewModel: viewModel.placeViewModel)
    }
}
