//
//  ReusableCollectionViewCell.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import UIKit

open class ReusableCollectionViewCell: UICollectionViewCell {
    /// Reuse Identifier String
    public class var reuseIdentifier: String {
        return "\(self.self)"
    }
    
    /// Registers the Nib with the provided table
    public static func registerwithCollectionView(_ collectionView: UICollectionView) {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: self.reuseIdentifier, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: self.reuseIdentifier)
    }
}
