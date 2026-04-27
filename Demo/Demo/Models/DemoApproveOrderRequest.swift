import Foundation
import CardPayments

struct DemoApproveOrderRequest {
    
    let card: Card
    let orderID: String
    let sca: SCA
}
