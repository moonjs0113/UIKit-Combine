# Intro

## Subscription and Publishers

```swift
import UIKit
import Combine 

extension Notification.Name {
 static let newBlogPost = Notification.Name("new_blog_post")
}

struct BlogPost {
 let title: String
 let url: URL
}

// Create a publisher
let blogPostPublisher = NotificationCenter.Publisher(center: .default, name: .newBlogPost, object: nil)
 .map { (notification) -> String? in
     return (notification.object as? BlogPost)?.title ?? ""
 }

// Create a subscriber
let lastPostLabel = UILabel()
let lastPostLabelSubscriber = Subscribers.Assign(object: lastPostLabel, keyPath: \.text)
blogPostPublisher.subscribe(lastPostLabelSubscriber)

// Post the notification
let blogPost = BlogPost(title: "Getting started with the Combine framework in Swift", url: URL(string: "https://www.avanderlee.com/swift/combine/")!)
NotificationCenter.default.post(name: .newBlogPost, object: blogPost)
print("Last post is: \(lastPostLabel.text!)")
```

## Rules of a subscription

- subscriber는 오직 하나의 subscription만 가질 수 있다
- 0개 이상의 값을 published 할 수 있다.
- 최대 하나의 completion(완료)가 호출된다.

## @Published

A property wrapper that adds a publisher to any property.

```swift
final class FormViewController: UIViewController {
 
 @Published var isSubmitAllowed: Bool = false
 
 @IBOutlet private weak var acceptTermsSwitch: UISwitch!
 @IBOutlet private weak var submitButton: UIButton!
 
 override func viewDidLoad() {
     super.viewDidLoad()
     $isSubmitAllowed // publisher
         .receive(on: DispatchQueue.main) // operators
         .assign(to: \.isEnabled, on: submitButton) // subscription
 }

 @IBAction func didSwitch(_ sender: UISwitch) {
     isSubmitAllowed = sender.isOn
 }
}
```

> Note: $ binding can only be used on *class* instances. Class is also `final`.

### Memory management

While this works:

```swift
$isSubmitAllowed // publisher
         .receive(on: DispatchQueue.main) // operators
         .assign(to: \.isEnabled, on: submitButton) // subscription
```

memory leaks과 retain cycles이 발생할 수 있다.   
Combine에서는 `AnyCancellable`로 해결한다.   
RxSwift에서 DisposeBag과 비슷한 개념을 추측된다.

```swift
 final class FormViewController: UIViewController {

     @Published var isSubmitAllowed: Bool = false
     private var switchSubscriber: AnyCancellable?

     @IBOutlet private weak var acceptTermsSwitch: UISwitch!
     @IBOutlet private weak var submitButton: UIButton!

     override func viewDidLoad() {
         super.viewDidLoad()
         
         /// Save the cancellable subscription.
         switchSubscriber = $isSubmitAllowed
             .receive(on: DispatchQueue.main)
             .assign(to: \.isEnabled, on: submitButton)
     }

     @IBAction func didSwitch(_ sender: UISwitch) {
         isSubmitAllowed = sender.isOn
     }
 } 
```

`AnyCancellable`은 subscription에 대한 참조를 명시적으로 추적함으로써, deinit에 `cancel()`를 호출하고 subscriptions이 조기 종료되고 retain cycles을 방지한다.

### Storing multiple subscriptions

```swift
 final class FormViewController: UIViewController {
 
     @Published var isSubmitAllowed: Bool = false
     private var subscribers: [AnyCancellable] = []
 
     @IBOutlet private weak var acceptTermsSwitch: UISwitch!
     @IBOutlet private weak var submitButton: UIButton!
 
     override func viewDidLoad() {
         super.viewDidLoad()
         
         $isSubmitAllowed
             .receive(on: DispatchQueue.main)
             .assign(to: \.isEnabled, on: submitButton)
             .store(in: &subscribers)
     }
 
     @IBAction func didSwitch(_ sender: UISwitch) {
         isSubmitAllowed = sender.isOn
     }
 } 
```

---

### Links that help

- [SwiftUI/Combine](https://github.com/jrasmusson/swiftui/tree/main/Combine)
