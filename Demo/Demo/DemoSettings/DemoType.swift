import UIKit
import SwiftUI

enum DemoType: String {
    case card
    case payPalWebCheckout
    case paymentButtonCustomization

    var viewController: UIViewController {
        let baseViewModel = BaseViewModel()

        switch self {
        case .card:
            return CardDemoViewController(baseViewModel: baseViewModel)
        case .payPalWebCheckout:
            return PayPalWebCheckoutViewController(baseViewModel: baseViewModel)
        case .paymentButtonCustomization:
            return PaymentButtonCustomizationViewController()
        }
    }

    var swiftUIView: some View {
        switch self {
        case .card:
            return AnyView(SwiftUICardDemo())
        case .payPalWebCheckout, .paymentButtonCustomization: // we do this until swiftUI is implemented
            return AnyView(SwiftUIPayPalDemo())
        }
    }
}
