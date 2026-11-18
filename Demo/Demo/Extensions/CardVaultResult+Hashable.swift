import CardPayments

extension CardVaultResult: @retroactive Hashable {
    
    public static func == (lhs: CardVaultResult, rhs: CardVaultResult) -> Bool {
        return lhs.setupTokenID == rhs.setupTokenID
        && lhs.status == rhs.status
        && lhs.didAttemptThreeDSecureAuthentication == rhs.didAttemptThreeDSecureAuthentication
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(setupTokenID)
        hasher.combine(status)
        hasher.combine(didAttemptThreeDSecureAuthentication)
    }
}
