import Foundation

public enum PayPalSessionType {
    case checkout
    case vaultWithoutPurchase
}

enum TokenType: String {
    case orderID = "ORDER_ID"
    case vaultID = "VAULT_ID"
    case billingToken = "BILLING_TOKEN"
}

extension PayPalSessionType {

    var tokenType: TokenType {
        switch self {
        case .checkout: return .orderID
        case .vaultWithoutPurchase: return .vaultID
        }
    }
}
