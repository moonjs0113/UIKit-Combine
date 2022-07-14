//
//  PlaceListController.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/14.
//

import UIKit
import Combine

class PlaceListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var viewModel: PlaceListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setUpUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareView(viewModel: PlaceListViewModel) {
        self.viewModel = viewModel
        observeEvents()
    }
    
    private func setUpUI() {
        titleLabel.text = viewModel.title
    }
    
    private func prepareTableView() {
        tableView.dataSource = self
        PlaceTableCell.registerWithTable(tableView)
    }
    
    private func observeEvents() {
        let placeSelectedCallback: (NearbyPlace) -> Void = { [weak self] place in
            DispatchQueue.main.async {
                self?.navigateToPlaceDetailScreenWithPlace(place)
            }
        }
        viewModel.placeSelected
            .sink(receiveValue: placeSelectedCallback)
            .store(in: &subscriptions)
    }
}

// MARK: Routing
extension PlaceListController {
    private func navigateToPlaceDetailScreenWithPlace(_ place: NearbyPlace) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "PlaceDetailController") as! PlaceDetailController
        let placeViewModel = PlaceDetailViewModel(place: place)
        controller.prepareView(viewModel: placeViewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
}


// MARK: UITableViewDataSource
extension PlaceListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableCell.reuseIdentifier, for: indexPath) as! PlaceTableCell
        cell.prepareCell(viewModel: viewModel.cellViewModel(indexPath: indexPath))
        return cell
    }
}
