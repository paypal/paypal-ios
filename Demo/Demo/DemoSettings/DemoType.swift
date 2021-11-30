import UIKit

enum DemoType: String {
    case card
    case paypal

    var viewController: UIViewController {
        let baseViewModel = BaseViewModel()

        switch self {
        case .card:
            return CardDemoViewController(baseViewModel: baseViewModel)
        case .paypal:
            return PayPalDemoViewController(baseViewModel: baseViewModel)
        }
    }
}
