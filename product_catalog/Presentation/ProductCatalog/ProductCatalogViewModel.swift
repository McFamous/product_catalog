import Combine
// MARK: - ProductCatalogViewModel
/// viewModel responsible for managing the state and logic for the product catalog
final class ProductCatalogViewModel {
    // MARK: - Properties
    /// repository responsible for fetching product data
    private let repository: ProductCatalogRepository
    /// limit of products per page request
    private let limit: Int = 20
    /// set to store cancellable subscriptions
    private var cancellables = Set<AnyCancellable>()
    /// state subject to publish changes in the catalog state
    let state = CurrentValueSubject<CatalogState, Never>(.initialState)

    // MARK: - Initialization
    // initializes the viewModel with a product repository
    init(repository: ProductCatalogRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// initializes products by loading the first page
    func initProducts() {
        let page = state.value.page
        fetchData(page: page)
    }
    /// loads the next page of products
    func getNextProducts() {
        let page = state.value.page + 1
        fetchData(page: page)
    }
    /// refreshes the product list, resetting to the initial state
    func refreshProducts() {
        state.send(.initialState)
        fetchData(page: 0)
    }

    // MARK: - Private Methods

    /// fetches product data for a specific page and updates the state
    private func fetchData(page: Int) {
        let currentState = state.value
        // prevents multiple requests if already loading or no more data is available
        if currentState.isLoading || !currentState.hasMoreData { return }
        
        // update state to loading
        state.send(currentState.copyWith(isLoading: true))
        // fetch products from the repository
        repository.getProducts(page: page, limit: limit)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let error) = completion else { return }
                    // update state with error information
                    let newState = CatalogState(page: page, products: [], isLoading: false, hasMoreData: false, error: error)
                    self?.state.send(newState)
                },
                receiveValue: { [weak self] products in
                    // update state with new product data
                    var updatedProducts = currentState.products
                    updatedProducts.append(contentsOf: products)
                    let newState = CatalogState(page: page, products: updatedProducts, isLoading: false, hasMoreData: !products.isEmpty, error: nil)
                    self?.state.send(newState)
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - CatalogState
/// represents the state of the product catalog
struct CatalogState {
    // MARK: - Static Properties

    /// initial state of the catalog
    static let initialState = CatalogState(page: 0, products: [], isLoading: false, hasMoreData: true, error: nil)

    // MARK: - Properties

    let page: Int
    let products: [Product]
    let isLoading: Bool
    let hasMoreData: Bool
    let error: ErrorType?

    // MARK: - Copy Method
    /// creates a copy of the current state with optional modified values
    func copyWith(
        page: Int? = nil,
        products: [Product]? = nil,
        isLoading: Bool? = nil,
        hasMoreData: Bool? = nil,
        error: ErrorType? = nil
    ) -> CatalogState {
        return CatalogState(
            page: page ?? self.page,
            products: products ?? self.products,
            isLoading: isLoading ?? self.isLoading,
            hasMoreData: hasMoreData ?? self.hasMoreData,
            error: error ?? self.error
        )
    }
}
