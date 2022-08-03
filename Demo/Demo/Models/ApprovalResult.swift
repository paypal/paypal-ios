struct ApprovalResult {

    let orderId: String
    let payerId: String

    init(orderId: String, payerId: String) {
        self.orderId = orderId
        self.payerId = payerId
    }
}
