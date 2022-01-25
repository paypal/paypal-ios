import Foundation

protocol PayPalCheckoutApprovalData {
    var intent: String { get }
    var payerID: String { get }
    var ecToken: String { get }
}
