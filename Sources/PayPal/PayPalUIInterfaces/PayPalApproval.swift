import Foundation
@_implementationOnly import PayPalCheckout

protocol PayPalCheckoutApprovalData {
    var intent: String { get }
    var payerID: String { get }
    var ecToken: String { get }
}

extension Approval: PayPalCheckoutApprovalData {
    var intent: String {
        return data.intent
    }

    var payerID: String {
        data.payerID
    }

    var ecToken: String {
        data.ecToken
    }
}
