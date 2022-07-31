# Combine + UIControl

# 0. Intro

Combine은 iOS 13부터 사용할 수 있는 Apple에서 개발한 Reactive framework이다.

기존에는 Reactive Programming을 위해 RxSwift를 대부분 사용해왔다.

RxSwift에는 RxCocoa라는 Cocoa 전용 기능을 제공하는 별도의 라이브러리가 존재했다.

하지만 Combine에는 아직 이러한 기능이 없어 UIElement의 Event Stream을 처리하는 하기위해서는 개발자가 직접 그 인터페이스를 구현해야한다.

# 1. Create a struct (with a generic type C) that conforms to Publisher protocol.
## **Publisher**
Publisher란 다음과 같이 정의되어 있다.

> Declares that a type can transmit a sequence of values over time.

프로세스를 시작하려면 먼저 subscribers가 요청을 보내고 가능한 경우 subscription을 받을 수 있는 publisher가 필요합니다.

Generic Type C는 `publisher`의 출력으로 사용되며, 현재 `Failure`는 `Never`로 설정됩니다.

C와 Event는  위해, initializer에서 struct 내부에 저장되어 참조됩니다.

또한 Subscription을 작성하기 위해 필요합니다.

> Memory leak을 피하기 위해 control은 weak로 선언합니다.

``` Swift 
struct InteractionPublisher<C: UIControl>: Publisher {
    typealias Output = C
    typealias Failure = Never
    
    private weak var control: C?
    private let event: UIControl.Event
    
    init(control: C, event: UIControl.Event) {
        self.control = control
        self.event = event
    }
    
    func receive<S>(
        subscriber: S
    ) where S : Subscriber, S.Failure == Never, C == S.Input {
        // Code
    }
}
```

`receive`된 method는 subscribe 요청을 확인하고 Subscription instance를 반환합니다. subscriber는 subscription을 사용하여 publisher에게 elements를 요구하고 이를 사용하여 publishing을 cancel할 수 있습니다.

# 2. Create a class (with S and C generic type) that conforms to Subscription and implement the methods.
## **Subscription**
Subscription이란 다음과 같이 정의되어 있다.

> A protocol representing the connection of a subscriber to a publisher.

`addTarget` method를 사용하여 `#selector`를 등록하고 events를 수신해야 하므로 이 단계는 control에 따라 다릅니다.

또한 Subscriber는 event에 대해 알림을 받아야 하므로 Subscriber에 대한 참조를 저장하는 것도 필수입니다.

handleEvent method에서 Subscriber는 event에 대한 알림을 받아야 합니다.

receive method를 호출하고 control을 argument로 전달하여 수행됩니다.

아시다시피 subscription은 DisposeBag를 dispose하려고 하면 cancel method가 호출되므로 보유하고 있던 모든 것을 버려야 합니다.

``` swift
class InteractionSubscription<S: Subscriber, C: UIControl>: Subscription where S.Input == C {
    private let subscriber: S?
    private weak var control: C?
    private let event: UIControl.Event
    
    init(subscriber: S, control: C?, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        self.event = event
        self.control?.addTarget(self, action: #selector(handleEvent), for: event)
    }
    
    @objc private func handleEvent(_ sender: UIControl) {
        guard let control = self.control else {
            return
        }
        _ = self.subscriber?.receive(control)
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        self.control?.removeTarget(self, action: #selector(handleEvent), for: self.event)
        self.control = nil
    }
}
```

# 3. Back to the Publisher.

먼저 control에 여전히 value가 있는지 확인합니다. 그렇지 않은 경우 subscriber에게 completion를 보냅니다. 이는 stream이 완료되었음을 의미합니다.

그런 다음 `InteractionSubscription`의 instance를 만들고 subscriber에게 제공합니다. `Publisher`가 `Subscriber`를 받으면 `subscription`을 하고 요청에 응답합니다.

``` swift
struct InteractionPublisher<C: UIControl>: Publisher {
    
    ...

    func receive<S>(
        subscriber: S
    ) where S : Subscriber, S.Failure == Never, C == S.Input {
        guard let control = control else {
            subscriber.receive(completion: .finished)
            return
        }
        
        let subscription = InteractionSubscription(
            subscriber: subscriber,
            control: control,
            event: event
        )
        
        subscriber.receive(subscription: subscription)
    }
}
```

# 4. Create a protocol that inherits from UIControl, and add method.

``` swift
protocol UIControlPublishable: UIControl { }

extension UIControlPublishable {
    
    func publisher(for event: UIControl.Event) -> UIControl.InteractionPublisher<Self> {
        
        return InteractionPublisher(control: self, event: event)
    }
}
extension UIControl: UIControlPublishable {
    class InteractionSubscription<S: Subscriber, C: UIControl>: Subscription where S.Input == C  {
        ...
    }

    struct InteractionPublisher<C: UIControl>: Publisher {
        ...
    }
}
```

# 5. Usage

이제 UIControl에서도 RxCocoa처럼 Combine을 사용할 수 있다!

```
class UIControlViewViewController: UIViewController {
    
    var subscriptions = Set<AnyCancellable>()
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button
            .publisher(for: .touchUpInside)
            .sink{ sender in
                print("\(sender) clicked")
            }
            .store(in: &subscriptions)
    }
}
```