//
//  ImageAndLabelCollectionCell.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import UIKit
import Combine
import Kingfisher

class ImageAndLabelCollectionCell: ReusableCollectionViewCell {
    private var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(named : "placeIcon")
        }
    }
    @IBOutlet weak var textLabel: UILabel!
    
    private var viewModel: ImageAndLabelCollectionCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func prepareCell(viewModel: ImageAndLabelCollectionCellViewModel) {
        self.viewModel = viewModel
        setUpUI()
    }
    
    private func setUpUI() {
        guard let viewModel = self.viewModel else { return }
        subscriptions = [
            viewModel.$text.assign(to: \.text, on: textLabel)
        ]
        
        viewModel.$assetName.map {
            guard let imageName = $0 else { return nil }
            return UIImage(named: imageName)
            }
        .assign(to: \.image, on: imageView)
        .store(in: &subscriptions)
        
        viewModel.$imageURL.compactMap {
            guard let imageURL = $0 else { return nil }
            return URL(string: imageURL)
        }
        .sink { [weak self] imageURL in
            self?.imageView.kf.setImage(with: imageURL,
                                        placeholder: UIImage(named : "placeIcon"),
                                        options: nil,
                                        progressBlock: nil) { result in
                switch result {
                case .success(let value):
                        break
                case .failure(let error):
                    self?.imageView.image = UIImage(named : "placeIcon")
                }
            }
        }
        .store(in: &subscriptions)
    }
    
}


