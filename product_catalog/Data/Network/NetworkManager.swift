import Foundation
import Combine

final class NetworkManager {
    private let baseUrl = "https://dummyjson.com"

    func getProducts(page: Int, limit: Int) -> AnyPublisher<ProductResponse, Error> {
        // request parameters
        let parameters = ["skip": "\(page * limit)", "limit": "\(limit)"]

        // create url with components
        guard var components = URLComponents(string: baseUrl + "/products") else {
            return Fail(error: ErrorType.unknownError).eraseToAnyPublisher()
        }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        // create final GET request
        guard let url = components.url else {
            return Fail(error: ErrorType.unknownError).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // use URLSession for sending request
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                // checking HTTP response
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw URLError(.badServerResponse) }
                return data
            }
            .decode(type: ProductResponse.self, decoder: JSONDecoder()) // decode response
            .eraseToAnyPublisher() // convert to AnyPublisher for flexibility
    }
}
