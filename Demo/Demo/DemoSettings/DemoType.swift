import UIKit
import SwiftUI

enum DemoType: String {
    case card
    case cardVault
    case payPalWebCheckout
    case paymentButtonCustomization
    case payPalNativeCheckout

    var swiftUIView: some View {
        switch self {
        case .card:
            return AnyView(CardPaymentView())
        case .cardVault:
            return AnyView(CardVaultView())
        case .payPalWebCheckout:
            return AnyView(PayPalWebView())
        case .paymentButtonCustomization:
            return AnyView(SwiftUIPaymentButtonDemo())
        case .payPalNativeCheckout:
            return AnyView(SwiftUINativeCheckoutDemo())
        }
    }
}
