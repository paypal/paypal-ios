import Foundation

/// Used to configure Vault request
public struct Vault {
    
    /// Optional. When set, the value of this property will be used to associate a payment method with the vault of a customer with this ID.
    /// If not specified a customer ID will be generated.
    public let customerID: String?

    /// Creates an instance of a vault object
    /// - Parameters:
    /// - customerID: Optional. When set, the value of this property will be used to associate a payment method with the vault of a customer with this ID.
    /// If not specified a customer ID will be generated.
    public init(customerID: String? = nil) {
        self.customerID = customerID
    }
}
