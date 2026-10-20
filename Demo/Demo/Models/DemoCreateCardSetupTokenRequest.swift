import Foundation
import CardPayments

@Observable
// TODO: rename to DemoCreateSetupTokenRequest
class DemoCreateCardSetupTokenRequest {
    
    var sca: SCA = .scaAlways
    var customerID = ""
}
