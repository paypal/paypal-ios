import Foundation

/// This class is used to configure a CardRequest for vaulting
public struct Vault {
    
    /// Property used to associate  a payment method with vault of customer with this ID
    public let customerID: String?

    /// Creates an instance of a vault object
    /// - Parameters:
    ///   - customerID: The identifier for customer. If not specified, PayPal will create one
    public init(customerID: String? = nil) {
        self.customerID = customerID
    }
}
