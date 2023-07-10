import UIKit
import SwiftUI

enum DemoType: String {
    case card
    case payPalWebCheckout
    case paymentButtonCustomization
    case payPalNativeCheckout

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
