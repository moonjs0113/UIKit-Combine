//
//  HomeViewController.swift
//  UIKitCombine
//
//  Created by Moon Jongseek on 2022/07/15.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        refreshScreen()
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var loadDataSubject = PassthroughSubject<Void, Never>()
    private var viewModel = HomeViewModel()
    
    var isRefreshInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        setupBindings()
        loadDataSubject.send()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Prepare the table view.
    private func prepareTableView() {
        tableView.dataSource = self
        
        PaginationCell.registerWithTable(tableView)
        CollectionTableCell.registerWithTable(tableView)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    /// Function to observe various event call backs from the viewmodel as well as Notifications.
    private func setupBindings() {
        viewModel.attachViewEventListener(loadData: loadDataSubject.eraseToAnyPublisher())
        
        viewModel.reloadplaceList
            .sink{ completion in
                // Error Handle
            } receiveValue: { [weak self] _ in
                ActivityIndicator.shared.hideActivityIndicator()
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.placeChoosed.sink { [weak self] place in
            self?.navigateToPlaceDetailScreenWithPlace(place)
        }
        .store(in: &subscriptions)
        
        viewModel.categoryChoosed.sink { [weak self] placeCategory in
            self?.navigateToPlaceListWithPlaceType(placeCategory)
        }
        .store(in: &subscriptions)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationAvailable(notification:)), name: Notification.Name("LocationAvailable"), object: nil)
    }
    
    /// Refresh the screen when refresh button is pressed.
    private func refreshScreen() {
        isRefreshInProgress = true
        ActivityIndicator.shared.displayActivityIndicator(onView: view)
        loadDataSubject.send()
    }
    
    /// Provides a paging cell.
    private func cellForPagingCell(indexPath: IndexPath, viewModel: PaginationCellViewModel)->PaginationCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaginationCell.reuseIdentifier, for: indexPath) as! PaginationCell
        cell.selectionStyle = .none
        cell.prepareCell(viewModel: viewModel)
        return cell
    }
    
    /// Provides a category cell.
    private func cellForCategoriesCell(indexPath: IndexPath, viewModel: TableCollectionCellRepresentable)->CollectionTableCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableCell.reuseIdentifier, for: indexPath) as! CollectionTableCell
        cell.selectionStyle = .none
        cell.prepareCell(viewModel: viewModel)
        return cell
    }
    
    /// Provides a places cell.
    private func cellForPlacesCell(indexPath: IndexPath, viewModel: TableCollectionCellRepresentable)->CollectionTableCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableCell.reuseIdentifier, for: indexPath) as! CollectionTableCell
        cell.selectionStyle = .none
        cell.prepareCell(viewModel: viewModel)
        return cell
    }
    
    /// Handler to observe notification events from LocationManager.
    @objc private func locationAvailable(notification: Notification) {
        guard !isRefreshInProgress else {
            return
        }
        refreshScreen()
    }
}

// MARK: Routing
extension HomeViewController {
    private func navigateToPlaceListWithPlaceType(_ placeType: PlaceType) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "PlaceListController") as! PlaceListController
        let placeViewVM = viewModel.getPlaceListViewModel(placeType: placeType)
        controller.prepareView(viewModel: placeViewVM)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func navigateToPlaceDetailScreenWithPlace(_ place: NearbyPlace) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "PlaceDetailController") as! PlaceDetailController
        let placeViewVM = PlaceDetailViewModel(place: place)
        controller.prepareView(viewModel: placeViewVM)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: UITableViewDatasource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModel.cellType(forIndex: indexPath)
        switch cellType {
        case .pagingCell(let model):
            return cellForPagingCell(indexPath: indexPath, viewModel: model)
        case .categoriesCell(model: let model):
            return cellForCategoriesCell(indexPath: indexPath, viewModel: model)
        case .placesCell(model: let model):
            return cellForPlacesCell(indexPath: indexPath, viewModel: model)
        }
    }
}
