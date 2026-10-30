import Foundation
import PayPalPayments

@Observable
class DemoUpdatePayPalSetupTokenRequest {
    
    var userAction: PayPalUserAction = .setupNow
    var userIdentity: UserIdentitySelection = .none
    var email = ""
    var phone = ""
    var ssid = ""
}
