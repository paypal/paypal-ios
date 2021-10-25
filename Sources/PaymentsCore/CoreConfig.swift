import Foundation

/// The configuration object containing information required by every payment method.
/// It is used to initialize all Client objects.
public struct CoreConfig {

    public let clientID: String
    public let environment: Environment

    /// Return URL required for PayPal integration
    public let returnUrl: String?

    public init(clientID: String, environment: Environment, returnUrl: String? = nil) {
        self.clientID = clientID
        self.environment = environment
        self.returnUrl = returnUrl
    }
}
