//
//  TermsViewController.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/05.
//

import UIKit
import Combine

class TermsViewController: UIViewController {
    
    // MARK: Publisher
    // Define publishers
    @Published private var acceptedTerms = false
    @Published private var acceptedPrivacy = false
    @Published private var name = ""
    
    // MARK: Properties
    // Combine publishers into single stream
    private var validToSubmit: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($acceptedTerms, $acceptedPrivacy, $name)
            .map { terms, privacy, name in
                return terms && privacy && !name.isEmpty
            }
            .eraseToAnyPublisher()
    }

    // Define subscriber
    private var buttonSubscriber: AnyCancellable?
    // AnyCancellable
    // - Need the subscriber to hang around for the life cycle of the view controller
    // - While not acting as a memory leak
    
    // MARK: IBOutlet
    @IBOutlet var acceptedSwitch: UISwitch!
    @IBOutlet var privacySwitch: UISwitch!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    // MARK: IBAction
    @IBAction func acceptTerms(_ sender: UISwitch) {
        acceptedTerms = sender.isOn
    }
    
    @IBAction func acceptPrivacy(_ sender: UISwitch) {
        acceptedPrivacy = sender.isOn
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        name = sender.text ?? ""
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        
        // Hook subscriber up to publisher
        buttonSubscriber = validToSubmit
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: submitButton)
    }
}


extension TermsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
