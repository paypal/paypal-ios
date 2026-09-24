
import CardPayments

extension CardResult: @retroactive Hashable {
    
    public static func == (lhs: CardResult, rhs: CardResult) -> Bool {
        return lhs.orderID == rhs.orderID
        && lhs.status == rhs.status
        && lhs.didAttemptThreeDSecureAuthentication == rhs.didAttemptThreeDSecureAuthentication
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(orderID)
        hasher.combine(status)
        hasher.combine(didAttemptThreeDSecureAuthentication)
    }
}
