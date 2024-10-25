// Entity product api
struct ProductApi: Codable {
    let id: Int
    let title: String
    let price: Double
    let stock: Int
    let images: [String]

    // Mapping productApi to domain product entity
    func toProduct() -> Product {
        return Product(
            id: id,
            title: title,
            images: images,
            price: price,
            stock: stock
        )
    }
}
