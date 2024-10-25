import UIKit

// MARK: - ProductViewCell
/// custom table view cell to display product information
final class ProductViewCell: UITableViewCell {
    // MARK: - Static Properties

    /// cell identifier for reuse
    static let identifier = "ProductViewCell"
    /// cache to store loaded images
    private static var imageCache = NSCache<NSString, UIImage>()

    // MARK: - Constants

    /// default padding around content in the cell
    private let defaultPadding: CGFloat = 12
    /// size for the product image
    private let imageSize = CGSize(width: 64, height: 64)

    // MARK: - Properties

    /// product model to populate cell content
    var product: Product? {
        didSet {
            guard let product = product else { return }
            /// reset image and update labels with product data
            productImageView.image = nil
            productNameLabel.text = product.title
            productStockLabel.text = "\(product.stock) ps."
            productPriceLabel.text = "\(product.price.toString(places: 2)) $"
            /// load product image if available
            if let imageString = product.images.first, let imageUrl = URL(string: imageString) {
                loadImage(imageUrl: imageUrl)
            }
        }
    }

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViewCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cell Configuration

    /// prevents the cell from remaining in the selected state
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected { self.setSelected(false, animated: true) }
    }

    /// setup and configures cell layout and constraints
    private func setupViewCell() {
        self.contentView.addSubview(contentContainer)
        self.contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: defaultPadding),
            contentContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -defaultPadding),
            contentContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: defaultPadding),
            contentContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -defaultPadding)
        ])
    }

    // MARK: - Subviews

    /// container holding all cell components
    private lazy var contentContainer: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
        return $0
    }(UIStackView(arrangedSubviews: [productImageView, productDescriptionContainer, productPriceLabel]))

    /// image view for displaying product image
    private lazy var productImageView: UIImageView = {
        $0.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        $0.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())

    /// container to hold product name and stock information
    private lazy var productDescriptionContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .fill
        return $0
    }(UIStackView(arrangedSubviews: [productNameLabel, productStockLabel]))

    /// label for product name
    private lazy var productNameLabel: UILabel = {
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .title2)
        $0.textColor = UIColor(named: "TitleColor")
        return $0
    }(UILabel())

    /// label for stock info
    private lazy var productStockLabel: UILabel = {
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.textColor = UIColor(named: "SubtitleColor")
        return $0
    }(UILabel())

    /// label for product price
    private lazy var productPriceLabel: UILabel = {
        $0.widthAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true
        $0.numberOfLines = 0
        $0.font = .preferredFont(forTextStyle: .title2)
        $0.textColor = UIColor(named: "TitleColor")
        $0.textAlignment = .right
        return $0
    }(UILabel())

    // MARK: - Image Loading

    /// loads image from URL, uses cache if available
    private func loadImage(imageUrl: URL) {
        let cacheKey = NSString(string: imageUrl.absoluteString)

        /// check if image is cached
        if let cachedImage = ProductViewCell.imageCache.object(forKey: cacheKey) {
            productImageView.image = cachedImage
            return
        }

        /// load image asynchronously and cache it
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let data = try? Data(contentsOf: imageUrl) else { return }
            guard let image = UIImage(data: data)?.resizeImage(scaledTo: self.imageSize) else { return }
            /// save image to cache
            ProductViewCell.imageCache.setObject(image, forKey: cacheKey)
            /// set the loaded image only if it matches the current product's image URL
            /// updating the interface on the main thread
            DispatchQueue.main.async { [weak self] in
                /// check that the cell still matches the image being loaded
                guard let currentImageString = self?.product?.images.first else { return }
                guard let currentImageUrl = URL(string: currentImageString) else { return }
                if currentImageUrl == imageUrl {
                    self?.productImageView.image = image
                }
            }
        }
    }
}
