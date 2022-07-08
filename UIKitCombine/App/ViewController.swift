//
//  ViewController.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func goToExample2(_ sender: UIButton) {
        let navigationController = UINavigationController(rootViewController: LoginViewController())
        if let _ = UserDataManager().token {
            navigationController.viewControllers = [LoginViewController(), MainMenuViewController()]
            navigationController.navigationBar.isHidden = true
        }
        self.present(navigationController, animated: true)
    }
    
    

}
