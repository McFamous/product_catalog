import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // setup rootViewController
        let networkManager = NetworkManager()
        let repository = DefaultProductCatalogRepository(networkManager: networkManager)
        let viewModel = ProductCatalogViewModel(repository: repository)
        let vc = ProductCatalogViewController()
        vc.bind(to: viewModel)

        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }
}
