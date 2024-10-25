import UIKit

// protocol can be adopted by any class that works with a ViewModel
// AnyObject constraint ensures this protocol is limited to class types
protocol BindableType: AnyObject {
    // associated type for a viewModel, which allows flexibility for any specific ViewModelType
    associatedtype ViewModelType

    // property to hold the viewModel instance
    var viewModel: ViewModelType! { get set }

    // method that must be implemented to bind data between viewModel and view
    func bindViewModel()
}

// this provides a default implementation for UIViewController that conform to BindableType
extension BindableType where Self: UIViewController {
    // method to setup viewModel and trigger viewController loading if needed
    func bind(to model: Self.ViewModelType) {
        viewModel = model
        loadViewIfNeeded() // ensures viewController is loaded before binding
        bindViewModel() // calls binding function to connect viewModel data to viewController
    }
}
