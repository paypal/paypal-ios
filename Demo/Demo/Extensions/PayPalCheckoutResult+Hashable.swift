import PayPalPayments

extension PayPalCheckoutResult: @retroactive Hashable {
    
    public static func == (lhs: PayPalCheckoutResult, rhs: PayPalCheckoutResult) -> Bool {
        return lhs.orderID == rhs.orderID && lhs.payerID == rhs.payerID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(orderID)
        hasher.combine(payerID)
    }
}
