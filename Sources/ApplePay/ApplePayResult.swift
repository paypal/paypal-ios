import Foundation

/// The PayPal order after the buyer authorizes Apple Pay.
///
/// Capture or authorize the order on your server. The SDK does not capture funds.
public struct ApplePayResult: Equatable {

    public let orderID: String
    public let status: String
}
