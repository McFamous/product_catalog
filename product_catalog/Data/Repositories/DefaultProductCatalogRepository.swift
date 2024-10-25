import Foundation
import Combine

final class DefaultProductCatalogRepository: ProductCatalogRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getProducts(page: Int, limit: Int) -> AnyPublisher<[Product], ErrorType> {
        return networkManager.getProducts(page: page, limit: limit)
            .mapError { _ in ErrorType.unknownError } // mapping error to domain entity
            .map { response in response.products.map { $0.toProduct() } } // mapping response to products array
            .receive(on: DispatchQueue.main) // switch to the main thread
            .eraseToAnyPublisher()
    }
}
