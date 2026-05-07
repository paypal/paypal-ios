import Foundation
import CardPayments

@Observable
class DemoApproveOrderRequest {
    
    var cardNumber: String = "4111 1111 1111 1111"
    var cardExpirationDate: String = "01 / 28"
    var cardCVV: String = "123"
    var sca: SCA = .scaAlways
}
