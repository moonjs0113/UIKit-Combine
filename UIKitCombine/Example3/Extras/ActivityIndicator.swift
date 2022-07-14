//
//  ActivityIndicator.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import UIKit

class ActivityIndicator {
    static let shared = ActivityIndicator()
    private var spinnerView = UIView()
    
    func displayActivityIndicator(onView: UIView) {
        spinnerView = .init(frame: onView.bounds)
        spinnerView.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView.init(style: .large)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.sync { [weak self] in
            guard let _self = self else {
                return
            }
            _self.spinnerView.addSubview(activityIndicator)
            onView.addSubview(_self.spinnerView)
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else {
                return
            }
            _self.spinnerView.removeFromSuperview()
        }
    }
}
