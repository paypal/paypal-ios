import Foundation
@_implementationOnly import PayPalCheckout

protocol PayPalCheckoutErrorInfo {
    var reason: String { get }
    var error: Error { get }
}

extension ErrorInfo: PayPalCheckoutErrorInfo { }
