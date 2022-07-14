//
//  ReusableTableViewCell.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import UIKit

open class ReusableTableViewCell: UITableViewCell {
    /// Reuse Identifier String
    public class var reuseIdentifier: String {
        return "\(self.self)"
    }
    /// Registers the Nib with the provided table
    public static func registerWithTable(_ table: UITableView) {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: self.reuseIdentifier, bundle: bundle)
        table.register(nib, forCellReuseIdentifier: self.reuseIdentifier)
    }
}
