//
//  LoginView.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/06.
//

import UIKit

class LoginView: UIView {
    // MARK: IBOutlet
    @IBOutlet var view: LoginView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameError: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: Property
    var unVisibility = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 1.0) {
                    self.userNameError.isHidden = self.unVisibility
                }
            }
        }
    }
    
    var pwVisibility = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {         UIView.animate(withDuration: 1.0, animations: {
                self.passwordError.isHidden = self.pwVisibility
            })
            }
        }
    }
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Method
    private func commonInit() {
        Bundle.main.loadNibNamed("LoginView", owner: self, options: .none)
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        userNameTextField.delegate = self
        
        // There is no error when we first load
        self.userNameError.isHidden = true
        self.passwordError.isHidden = true
        
        self.userNameError.text = "Username Must be > \(passwordLength) characters"
        self.passwordError.text = "Password Must be > \(passwordLength) characters"
        
        // and the login button will be disabled
        self.loginButton.isEnabled = false
    }
}


// MARK: UITextFieldDelegate
extension LoginView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // output entire chenge from UITextField
         print(textField.text ?? "", string)
        return true
    }
}
