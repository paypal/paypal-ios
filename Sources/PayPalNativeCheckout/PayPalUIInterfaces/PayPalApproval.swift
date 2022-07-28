import Foundation
@_implementationOnly import PayPalCheckout

protocol PayPalCheckoutApprovalData {
    var intent: ApprovalOrderIntent { get }
    var payerID: String { get }
    var ecToken: String { get }
}

extension Approval: PayPalCheckoutApprovalData {

    var intent: ApprovalOrderIntent {
        data.intent
    }

    var payerID: String {
        data.payerID
    }

    var ecToken: String {
        data.ecToken
    }
}
