import Foundation
import CardPayments

class DemoApproveOrderRequest: ObservableObject {
    
    @Published var cardNumber: String = "4111 1111 1111 1111"
    @Published var cardExpirationDate: String = "01 / 28"
    @Published var cardCVV: String = "123"
    @Published var sca: SCA = .scaAlways
}
