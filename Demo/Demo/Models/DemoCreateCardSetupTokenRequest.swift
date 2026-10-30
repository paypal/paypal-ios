import Foundation
import CardPayments

@Observable
class DemoCreateCardSetupTokenRequest {
    
    var sca: SCA = .scaAlways
    var customerID = ""
}
