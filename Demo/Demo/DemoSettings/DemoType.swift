import UIKit
import SwiftUI

enum DemoType: String {
    case card
    case payPalWebCheckout
    case paymentButtonCustomization
    case payPalNativeCheckout

    var viewController: UIViewController {
        let baseViewModel = BaseViewModel()

        switch self {
        case .card:
            return CardDemoViewController(baseViewModel: baseViewModel)
        case .payPalWebCheckout:
            return PayPalWebCheckoutViewController(baseViewModel: baseViewModel)
        case .paymentButtonCustomization:
            return PaymentButtonCustomizationViewController()
        case .payPalNativeCheckout:
            return NativeCheckoutDemoViewController(baseViewModel: baseViewModel)
        }
    }

    var swiftUIView: some View {
        switch self {
        case .card:
            return AnyView(SwiftUICardDemo())
        case .payPalWebCheckout:
            return AnyView(SwiftUIPayPalDemo())
        case .paymentButtonCustomization:
            return AnyView(SwiftUIPaymentButtonDemo())
        case .payPalNativeCheckout:
            return AnyView(SwiftUINativeCheckoutDemo())
        }
    }
}
