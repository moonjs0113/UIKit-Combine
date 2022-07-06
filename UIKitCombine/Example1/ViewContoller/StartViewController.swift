//
//  ViewController.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/05.
//

import UIKit
import Combine

class StartViewController: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var blogTextField: UITextField!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var subscribedLabel: UILabel!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishButton.addTarget(self, action: #selector(publishButtonTapped), for: .primaryActionTriggered)
        
        // Create a publisher
        let publisher = NotificationCenter.Publisher(center: .default, name: .newBlogPost, object: nil)
         .map { (notification) -> String? in // Combine with an operator
             return (notification.object as? BlogPost)?.title ?? ""
         }
        
        // Create a subscriber
        let subscriber = Subscribers.Assign(object: subscribedLabel, keyPath: \.text)
        publisher.subscribe(subscriber)
    }
    
    @objc func publishButtonTapped(_ sender: UIButton) {
        // Post the notification
        let title = blogTextField.text ?? "Coming soon"
        let blogPost = BlogPost(title: title)
        NotificationCenter.default.post(name: .newBlogPost, object: blogPost)
    }
}

