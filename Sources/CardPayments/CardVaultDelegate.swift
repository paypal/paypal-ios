import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// CardVault delegate to handle events from CardClient
@available(*, deprecated, message: "This protocol is deprecated and will be removed in a future release. Use the new completion handler-based approach instead.")
public protocol CardVaultDelegate: AnyObject {
    
    /// Notify that the Card vault flow finished with a successful result
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    ///   - didFinishWithResult: the successful result from the flow
    func card(_ cardClient: CardClient, didFinishWithVaultResult vaultResult: CardVaultResult)
    
    /// Notify that an error occurred in the Card vault flow
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    ///   - didFinishWithError: the error returned by the Card vault flow
    func card(_ cardClient: CardClient, didFinishWithVaultError vaultError: CoreSDKError)

    /// Notify that the ThreeDSecure has been cancelled
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    func cardThreeDSecureDidCancel(_ cardClient: CardClient)

    /// Notify that the 3DS challenge will be launched
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    func cardThreeDSecureWillLaunch(_ cardClient: CardClient)

    /// Notify that the 3DS challenge has finished
    /// - Parameters:
    ///   - client: the CardClient associated with delegate
    func cardThreeDSecureDidFinish(_ cardClient: CardClient)
}
