// Entity of /products response
struct ProductResponse: Codable {
    let products: [ProductApi]
    let total: Int
    let skip: Int
    let limit: Int
}
