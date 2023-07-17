import Foundation

public struct Vault {
    
    public let customerID: String?

    public init(customerID: String? = nil) {
        self.customerID = customerID
    }
}
