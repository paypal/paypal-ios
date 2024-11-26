import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Card delegate to handle events from CardClient
@available(*, deprecated, message: "This protocol is deprecated and will be removed in version 2.0.0. Please use the new completion handler-based approach instead. For more details, visit the v2 migration guide: https://github.com/paypal/paypal-ios/")
public protocol CardDelegate: AnyObject {

    /// Notify that the Card flow finished with a successful result
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    ///   - didFinishWithResult: the successful result from the flow
    func card(_ cardClient: CardClient, didFinishWithResult result: CardResult)

    /// Notify that an error occurred in the Cardl flow
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    ///   - didFinishWithError: the error returned by the Card flow
    func card(_ cardClient: CardClient, didFinishWithError error: CoreSDKError)

    /// Notify that the Card flow has been cancelled
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    func cardDidCancel(_ cardClient: CardClient)

    /// Notify that the 3DS challenge will be launched
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    func cardThreeDSecureWillLaunch(_ cardClient: CardClient)

    /// Notify that the 3DS challenge has finished
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    func cardThreeDSecureDidFinish(_ cardClient: CardClient)
}
