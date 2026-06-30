import Foundation

/// The configuration object containing information required by every payment method.
/// It is used to initialize all Client objects.
public struct CoreConfig {

    public let environment: Environment
    public let clientID: String
    public let merchantID: String
    public let bnCode: String?

    public init(clientID: String, environment: Environment, merchantID: String, bnCode: String? = nil) {
        self.environment = environment
        self.clientID = clientID
        self.merchantID = merchantID
        self.bnCode = bnCode
    }
}
