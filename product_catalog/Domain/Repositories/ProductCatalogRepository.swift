import Combine

protocol ProductCatalogRepository {
    func getProducts(page: Int, limit: Int) -> AnyPublisher<[Product], ErrorType>
}
