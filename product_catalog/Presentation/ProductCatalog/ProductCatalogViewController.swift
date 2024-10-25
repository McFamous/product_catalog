import UIKit
import Combine
// MARK: - ProductCatalogViewController
/// controller for displaying product catalog in table view
final class ProductCatalogViewController: UIViewController, BindableType {
    // MARK: - Properties

    /// set to store cancellable subscriptions
    private var cancellables = Set<AnyCancellable>()
    /// viewModel providing data and business logic
    var viewModel: ProductCatalogViewModel!

    // MARK: - Binding ViewModel
    /// binds viewController to viewModel to respond to state changes
    func bindViewModel() {
        viewModel.state
            .sink { [weak self] in
                /// show or hide error background view depending on the presence of an error
                self?.productCatalogTableView.backgroundView = $0.error == nil ? nil : self?.backgroundView
                /// reload table data
                self?.productCatalogTableView.reloadData()
                // end refresh control if refreshing
                if self?.refreshControl.isRefreshing == true {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Lifecycle Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.initProducts()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // configure view background color
        self.view.backgroundColor = UIColor(named: "BackgroundColor")
        // add and layout product catalog table view
        self.view.addSubview(productCatalogTableView)
        self.view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            productCatalogTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            productCatalogTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            productCatalogTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            productCatalogTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    // MARK: - Subviews

    /// tableView to display products array
    private lazy var productCatalogTableView: UITableView = {
        $0.register(ProductViewCell.self, forCellReuseIdentifier: ProductViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.refreshControl = refreshControl
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 88
        $0.showsVerticalScrollIndicator = true
        $0.contentInsetAdjustmentBehavior = .always
        return $0
    }(UITableView())

    /// refresh control for reloading data manually
    private lazy var refreshControl: UIRefreshControl = {
        $0.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return $0
    }(UIRefreshControl())

    /// background view displaying error message when there's an error
    private lazy var backgroundView: ErrorBackgroundView = {
        $0.refreshButton.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
        return $0
    }(ErrorBackgroundView())

    /// action for refreshing data
    @objc private func refreshData() {
        viewModel.refreshProducts()
    }
}

// MARK: - UITableViewDelegate

extension ProductCatalogViewController: UITableViewDelegate {
    /// loads more products when nearing the end of the product list
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == viewModel.state.value.products.count - 2 else { return }
        viewModel.getNextProducts()
    }
}

// MARK: - UITableViewDataSource

extension ProductCatalogViewController: UITableViewDataSource {
    /// returns the number of products to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.state.value.products.count
    }

    /// configures and returns the cell for a specific product
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductViewCell.identifier, for: indexPath) as! ProductViewCell
        cell.product = viewModel.state.value.products[indexPath.row]
        return cell
    }
}
