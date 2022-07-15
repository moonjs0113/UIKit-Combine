# How to Use UIKit With MVVM and Combine
![MVVM](images/MVVM.png)

## **Configuring the ViewModel**

![Place Detail](images/PlaceDetail.png)

PlaceDetail에서는 장소의 이름, 위치, 이미지, 운영상태 및 거리를 표시한다.
이러한 정보는 `ViewModel`가 `View`에게 전달한다.

``` swift
class PlaceDetailViewModel {
    // MARK: Output
    @Published private(set) var title = ""
    @Published private(set) var distance = ""
    @Published private(set) var isOpen = false
    @Published private(set) var placeImageUrl: String = ""
    @Published private(set) var location: CLLocation? = nil
    
    private let place: NearbyPlace
    
    init(place: NearbyPlace) {
        self.place = place
        configureOutput()
    }
    
    private func configureOutput() {
        title = place.name
        let openStat = place.openStatus ?? false
        isOpen = openStat
        location = place.location
        placeImageUrl = place.imageURL ?? ""
        
        let currentLocation = CLLocation(latitude: LocationManager.sharedManager.latitude, longitude: LocationManager.sharedManager.longitude)
        guard let distance = place.location?.distance(from: currentLocation) else { return }
        self.distance = String(format: "%.2f mi", distance/1609.344)
    }
}
```

## **What’s going on here?**
`ViewModel`은 특정 장소에 대한 모든 정보가 담긴 `NearbyPlace`를 받고, Output을 설정한다.
Output은 `View`에 표시될 데이터이다.

모든 Output properties에는 `@Published`로 선언되어 있다.

Combine의 publisher property wrapper는 속성이 변경될 때마다 업데이트된 값을 수신한다.

원래는 Update callback or delegate를 통한 callback을 해야했다.

## **Configuring the View**
``` swift
class PlaceDetailController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    
    private var viewModel: PlaceDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        // Properties that can be assigned using default assign method
        subscriptions = [
            viewModel.$title.assign(to: \.text!, on: titleLabel),
            viewModel.$distance.assign(to: \.text!, on: distanceLabel),
            viewModel.$isOpen.map { $0.openStatusText }.assign(to: \.text!, on: openStatusLabel),
            viewModel.$isOpen.map { $0 ? UIColor.green : UIColor.red }.assign(to: \.textColor!, on: openStatusLabel)
        ]
        
        // Properties require custom assigning
        viewModel.$placeImageUrl.compactMap { URL(string: $0) }
        .sink { [weak self] imageURL in
            self?.placeImageView.kf.setImage(with: imageURL, placeholder: UIImage(named : "placeIcon"), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                })
        }
        .store(in: &subscriptions)
        
        viewModel.$location.compactMap { location -> (MKCoordinateRegion, MKPointAnnotation)? in
            guard let lat = location?.coordinate.latitude,
                let long = location?.coordinate.longitude else { return nil }
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            return (region, annotation)
        }.sink { [weak self] location in
            self?.mapView.setRegion(location.0, animated: true)
            self?.mapView.addAnnotation(location.1)
        }.store(in: &subscriptions)
    }
    
    }
```
`View`가 로드되면 UI components에 대한 `ViewModel` 구성 출력 속성의 Binding을 설정합니다.

Binding이라 부르는 이유는 UI Components를 해당 값에 할당할 뿐만 아니라 해당 속성의 변경 사항도 subscribing하기 때문이다. 

`assign(to:on:)`

모든 assignment의 결과는 `AnyCancellable` type이다.

`$title`를 `titleLabel`의 `text` property에 할당하기 위해서는 `viewModel.$title.assign(to: \.text!, on: titleLabel)`를 사용한다.

모든 `AnyCancellable`의 결과는 메모리에 남아있는 `subscriptions`에 저장시켜 subscriptions가 다음 Events를 수신할 수 있도록 한다.

## **Custom Assigning**
Attributes의 custom handling을 위해 `sink(receiveValue:)` 및 `handleEvents` 같은 `Publishers`를 통해 Combine에서 제공하는 다양한 operators를 사용하여 값을 수신하고 작업할 수 있다.

위의 code snippet에서는 `compactMap`를 사용하여 `$location` publisher의 `CLLocation` Value 스크림을 `MKCoordinateRegion`과 `MKPointAnnotation`의 Tuple에 mapping한 다음 `sink`를 사용하여 지도에 세부 정보를 렌더링한다.

## **Passing UI Events to the ViewModel**
API call, a database query 등 추가 프로세스를 위해 특정 UI events를 `ViewModel`에 전달해야할 때가 있다.

![NearbyHome](images/NearbyHome.png)

위 화면에서는 피드 새로고침, 카테고리 tap 등 특정 UI Events가 View에서 발생한다.

이러한 이벤트는 API trigger 또는 UI 자체와 같은 `ViewModel`에서 특정 작업을 trigger한다.

사용자가 화면 데이터를 새로 고치는 방법에 대해 알아보자.

### HomeViewController
``` swift
// HomeViewController
class HomeViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    private var loadDataSubject = PassthroughSubject<Void,Never>()
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setupBinding()
        loadDataSubject.send()
    }
    
    private func setupBinding() {
        viewModel.attachViewEventListener(loadData: loadDataSubject.eraseToAnyPublisher())
        viewModel.reloadPlaceList
            .sink(receiveCompletion: { completion in
                // Handle the error
            }) { [weak self] _ in
                ActivityIndicator.sharedIndicator.hideActivityIndicator()
                self?.tableView.reloadData()
        }
        .store(in: &subscriptions)
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        ActivityIndicator.sharedIndicator.displayActivityIndicator(onView: view)
        loadDataSubject.send()
    }
}
```

### HomeViewModel
``` swift
// HomeViewModel
class HomeViewModel {
  var reloadPlaceList: AnyPublisher<Result<Void, NearbyAPIError>, Never> {
        reloadPlaceListSubject.eraseToAnyPublisher()
   }
  
  // MARK: Input
    private var loadData: AnyPublisher<Void, Never> = PassthroughSubject<Void, Never>().eraseToAnyPublisher()
    private let reloadPlaceListSubject = PassthroughSubject<Result<Void, NearbyAPIError>, Never>()
  
    func attachViewEventListener(loadData: AnyPublisher<Void, Never>) {
        self.loadData = loadData
        self.loadData
            .setFailureType(to: NearbyAPIError.self)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.allPlaces.removeAll()
            })
            .flatMap { _ -> AnyPublisher<[NearbyPlace], NearbyAPIError> in
                let placeWebservice = PlaceWebService()
                return placeWebservice
                    .fetchAllPlaceList()
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.tableDataSource.removeAll()
            })
            .sink(receiveCompletion: { _ in },
              receiveValue: { [weak self] places in
                self?.allPlaces.append(contentsOf: places)
                self?.prepareTableDataSource()
                self?.reloadPlaceListSubject.send(.success(()))
            })
            .store(in: &subscriptions)
    }
}
```
`PassthroughSubject`를 사용하여 subscribers에게 events를 보낼 수 있습니다.

이 경우 `loadDataSubject`는 View에서 Events를 `ViewModel`로 전송하여 server에서 app data를 load하는데 사용된다. 사용자가 새로고침버튼을 누르거나 View 처음 Load 될 때마다 `ViewModel`에 data를 load하도록 요청한다.  `AnyPublisher`는 Event를 수신할 때만 사용할 수 있고 전송할 수는 없다. `eraseToAnyPublisher`를 사용하여 `ViewModel`의 `loadDataSubject`가 남용될 가능성을 피할 수 있다. `ViewModel`와 `View`간의 통신도 이와 비슷하다. 성공적인 API fetch를 위해 `reloadPlaceList: AnyPublisher<Result<Void, NearbyAPIError>, Never>`를 사용한다.

## **Pain of UIKit and Combine Compatibility**
## Missing bindings
Key Path를 사용하여 publisher를 속성에 Binding 하는 `assign(to:on:)`이 있지만, Rx에서 사용되는 `bind(to:)`와 같이 일부 주요 바인딩 기능은 뒤떨어져있다. 특히 `UIControl`의 경우 `AnyPublisher`로 제어 Events를 보내는 단순한 방법이 없다. 이 프로젝트에서도 Button의 Tap Events를 `PublishSubject`과 `eraseToAnyPublisher`를 사용하여 전송했다.

To implement a UIControl binding functionality such as assign, we have to write our own custom publisher which is a lot of overhead for anyone.

Don’t be disheartened. We can still use combine to drive many of our business logic asynchronously and exploit the power of Combine and reactive programming.

## Property Wrappers and Protocols
Protocol에서는 Property wrappers를 못쓴다. `View`에서 `ViewModel`를 직접 사용했기 때문에 `View`의 재사용성이 떨어진다.

[Protocol과 @Published를 함께 쓰는 방법](https://swiftsenpai.com/swift/define-protocol-with-published-property-wrapper/?utm_campaign=AppCoda%20Weekly&utm_medium=email&utm_source=Revue%20newsletter)

## MVVM Sample
[MVVM Practice](https://github.com/gabhisekdev/MVVMDiscussion)