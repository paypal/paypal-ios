import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

struct GetOrderInfoRequest: APIRequest {

    typealias ResponseType = GetOrderInfoResponse

    let pathFormat: String = "v2/checkout/orders/%@"
    let token: String
    var path: String
    var method: HTTPMethod = .get
    var body: Data?

    var headers: [HTTPHeader: String] {
        return [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer \(token)"
        ]
    }

    /// Creates request to get the order information
    init(orderID: String, token: String) {
        self.token = token
        path = String(format: pathFormat, orderID)
    }
}
