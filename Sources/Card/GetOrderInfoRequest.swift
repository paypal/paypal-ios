import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

struct GetOrderInfoRequest: APIRequest {

    typealias ResponseType = GetOrderInfoResponse

    let clientID: String
    let pathFormat: String = "v2/checkout/orders/%@"

    var path: String
    var method: HTTPMethod = .get
    var body: Data?

    var headers: [HTTPHeader: String] {
        let encodedClientID = "\(clientID)".data(using: .utf8)?.base64EncodedString() ?? ""

        return [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Basic \(encodedClientID)"
        ]
    }

    /// Creates request to get the order information
    init(orderID: String, clientID: String) {
        self.clientID = clientID
        path = String(format: pathFormat, orderID)
    }
}
