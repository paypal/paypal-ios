import UIKit
import SwiftUI

enum DemoType: String {
    case card
    case payPalWebCheckout

    var viewController: UIViewController {
        let baseViewModel = BaseViewModel()

        switch self {
        case .card:
            return CardDemoViewController(baseViewModel: baseViewModel)
        case .payPalWebCheckout:
            return PayPalWebCheckoutViewController(baseViewModel: baseViewModel)
        }
    }

    var swiftUIView: some View {
        switch self {
        case .card:
            return AnyView(SwiftUICardDemo())
        case .payPalWebCheckout:
            return AnyView(SwiftUIPayPalDemo())
        }
    }
}
