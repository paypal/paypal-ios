import UIKit
import SwiftUI

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

    var swiftUIView: some View {
        switch self {
        case .card:
            return AnyView(SwiftUICardDemo())
        case .paypal:
            return AnyView(SwiftUIPayPalDemo())
        }
    }
}
