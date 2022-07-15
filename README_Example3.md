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
There are times when we need to pass certain UI events to the `ViewModel` for further processes — perhaps an API call, a database query, or something else.

![NearbyHome](images/NearbyHome.png)

The above screen shows the Nearby home page. Certain UI events occur on this view — user taps to refresh the feed, taps on category, taps on any place, etc. These events trigger certain actions in the `ViewModel` , like triggering the API or on the UI itself, in navigation for instance. For our discussion,let’s take a communication where the user taps to refresh data on screen:

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

A `PassthroughSubject` can be used to send events to subscribers of your subject. Think of this as your water supply pipe from which you take your daily water supply.

In our case the `loadDataSubject` is used by the view to send events to the `ViewModel` to load app data from the server. Whenever the user presses on the refresh button or the view loads for the first time we ask the `ViewModel` to load the data. If you closely look at the `attachViewEventListener(loadData: AnyPublisher<Void, Never>)` implemented in the `ViewModel`, we do not actually pass the `loadDataSubject` to the `ViewModel` to receive the event. Rather we type erase the subject to an `AnyPublisher` and send it. An `AnyPublisher` can only be used to receive events and not send events. By using this type erasure we are avoiding any chance of abuse of the `loadDataSubject` from the `ViewModel`.

A similar approach goes for communication between `ViewModel` and `View`. For reloading our list on a successful API fetch, we use `reloadPlaceList: AnyPublisher<Result<Void, NearbyAPIError>, Never>`

## **Pain of UIKit and Combine Compatibility**
## Missing bindings
Though we have `assign(to:on:)` which uses the key path to bind a publisher to any property, it lags some major binding functionality as its Rx counterpart `bind(to:)` has. Especially for `UIControl`, there’s no straightforward way to send control events to a `AnyPublisher` property. In our case, we’ve used `PublishSubject` and type erasures to send a button tap event. The community was pretty quick to develop wrappers for missing binding functionality for `UIKit` components.

To implement a UIControl binding functionality such as assign, we have to write our own custom publisher which is a lot of overhead for anyone.

Don’t be disheartened. We can still use combine to drive many of our business logic asynchronously and exploit the power of Combine and reactive programming.

## **Property Wrappers and Protocols**
Property wrappers can not be declared in protocol definitions. You may have noticed, we used our `ViewModel`s directly in the view, using their concrete types. This reduces the scope of the reusability of our views. If we were to abstract out `ViewModel`s and expose our outputs and inputs by protocols, we could not use `@Published` directly in protocol definitions. The reason and the workaround are explained in this blog. Feel free to check that out.

## MVVM Sample
[MVVM Practice](https://github.com/gabhisekdev/MVVMDiscussion)