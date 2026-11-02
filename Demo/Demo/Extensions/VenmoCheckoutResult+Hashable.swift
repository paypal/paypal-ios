import VenmoPayments

extension VenmoCheckoutResult: @retroactive Hashable {

    public static func == (lhs: VenmoCheckoutResult, rhs: VenmoCheckoutResult) -> Bool {
        return lhs.orderID == rhs.orderID && lhs.payerID == rhs.payerID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(orderID)
        hasher.combine(payerID)
    }
}
