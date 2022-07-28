import Foundation
import PaymentsCore

enum NativeCheckoutResult {
    case approved(ApprovalResult)
    case error(CoreSDKError)
    case cancel
}
