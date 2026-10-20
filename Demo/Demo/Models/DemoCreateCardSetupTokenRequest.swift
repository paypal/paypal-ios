import Foundation
import CardPayments

// TODO: rename to DemoCreateSetupTokenRequest
@Observable
class DemoCreateCardSetupTokenRequest {
    
    var sca: SCA = .scaAlways
    var customerID = ""
}
