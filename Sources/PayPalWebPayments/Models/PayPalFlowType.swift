import Foundation

public enum TokenType: String {
    case orderID = "ORDER_ID"
    case vaultID = "VAULT_ID"
    case billingToken = "BILLING_TOKEN"

    var tokenQueryParameterName: String {
        switch self {
        case .orderID: return "token"
        case .vaultID: return "approval_session_id"
        case .billingToken: return "token"
        }
    }
}
