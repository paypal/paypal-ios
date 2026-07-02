import Foundation

/// The configuration object containing information required by every payment method.
/// It is used to initialize all Client objects.
public struct CoreConfig {

    public let environment: Environment
    public let clientID: String

    /// The PayPal merchant account identifier associated with this integration.
    public let merchantID: String

    /// The partner attribution (BN) code assigned by PayPal to your platform or partner integration.
    /// Set this when processing payments on behalf of merchants through a PayPal partner program.
    public let bnCode: String?

    public init(clientID: String, environment: Environment, merchantID: String, bnCode: String? = nil) {
        self.environment = environment
        self.clientID = clientID
        self.merchantID = merchantID
        self.bnCode = bnCode
    }
}
