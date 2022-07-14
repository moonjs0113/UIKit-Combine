//
//  PlaceDetailController.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import UIKit
import MapKit
import CoreLocation
import Kingfisher
import Combine

class PlaceDetailController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var openStatusLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: PlaceDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareView(viewModel: PlaceDetailViewModel) {
        self.viewModel = viewModel
    }
    
    private func setupBindings() {
        subscriptions = [
            viewModel.$title.assign(to: \.text!, on: titleLabel),
            viewModel.$distance.assign(to: \.text!, on: distanceLabel),
            viewModel.$isOpen.map { $0.openStatusText }.assign(to: \.text!, on: openStatusLabel),
            viewModel.$isOpen.map { $0 ? UIColor.green : UIColor.red }.assign(to: \.textColor!, on: openStatusLabel)
        ]
        
        viewModel.$placeImageUrl.compactMap{ URL(string: $0) }
            .sink { [weak self] imageURL in
                self?.placeImageView.kf.setImage(with: imageURL,
                                                 placeholder: UIImage(named: "placeIcon"))
            }
            .store(in: &subscriptions)
        
        viewModel.$location.compactMap { location -> (region: MKCoordinateRegion, annotation: MKPointAnnotation)? in
            guard let lat = location?.coordinate.latitude,
                  let lng = location?.coordinate.longitude else {
                return nil
            }
            
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let region = MKCoordinateRegion(center: center,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            return (region, annotation)
        }
        .sink { [weak self] location in
            self?.mapView.setRegion(location.region, animated: true)
            self?.mapView.addAnnotation(location.annotation)
        }
        .store(in: &subscriptions)
    }
    
    
}
