import UIKit

enum DemoType: String {
    case card
    case paypal

    var viewController: UIViewController.Type {
        switch self {
        case .card:
            return CardDemoViewController.self
        case .paypal:
            return PayPalDemoViewController.self
        }
    }
}
