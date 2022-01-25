import Foundation

protocol PayPalCheckoutErrorInfo {
    var reason: String { get }
    var error: Error { get }
}
