import Foundation
import PayPalPayments

@Observable
class DemoUpdatePayPalSetupTokenRequest {
    
    var userAction: PayPalUserAction = .payNow
    var userIdentity: UserIdentitySelection = .none
    var email = ""
    var phone = ""
    var ssid = ""
}
