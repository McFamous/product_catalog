import UIKit
// MARK: - ErrorBackgroundView

/// custom view that displays an error message with a refresh button
final class ErrorBackgroundView: UIView {

    // MARK: - Initializers

    /// default initializer
    init() {
        super.init(frame: .zero)
        setupView()
    }

    /// required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup View

    /// sets up the view by adding and positioning the `contentContainer` (UIStackView)
    private func setupView() {
        self.addSubview(contentContainer)
        self.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            contentContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    // MARK: - Subviews

    /// container for the error message label and refresh button, arranged vertically
    private lazy var contentContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .center
        return $0
    }(UIStackView(arrangedSubviews: [errorLabel, refreshButton]))

    /// label displaying error message
    private lazy var errorLabel: UILabel = {
        $0.text = "Unexpected error"
        $0.textColor = UIColor(named: "TitleColor")
        $0.font = .preferredFont(forTextStyle: .title2)
        return $0
    }(UILabel())

    /// button to trigger a refresh action; `private(set)` allows read access but restricts write access
    private(set) lazy var refreshButton: UIButton = {
        $0.setTitle("Try again", for: .normal)
        return $0
    }(UIButton(type: .system))
}
