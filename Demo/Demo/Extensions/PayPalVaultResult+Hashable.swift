import PayPalPayments

extension PayPalVaultResult: @retroactive Hashable {
    
    public static func == (lhs: PayPalVaultResult, rhs: PayPalVaultResult) -> Bool {
        return lhs.tokenID == rhs.tokenID && lhs.approvalSessionID == rhs.approvalSessionID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tokenID)
        hasher.combine(approvalSessionID)
    }
}
