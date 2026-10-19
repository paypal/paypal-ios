import Foundation
import PayPalPayments

@Observable
class DemoApproveOrderWithPayPalRequest {
    
    var userAction: PayPalUserAction = .payNow
    var userIdentity: UserIdentitySelection = .none
    var email = ""
    var phone = ""
    var ssid = ""
    var amount = "10.00"
}
