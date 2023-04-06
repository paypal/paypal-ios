#if canImport(CorePayments)
import CorePayments
#endif

struct GetOrderAmountRequest: APIRequest {

    private let pathFormat: String = "v2/checkout/orders/%@"
    private let accessToken: String

    init(orderID: String, accessToken: String) {
        self.accessToken = accessToken
        path = String(format: pathFormat, orderID)
    }

    // MARK: - APIRequest

    typealias ResponseType = GetOrderAmountResponse

    var path: String
    var method: HTTPMethod = .get

    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer \(accessToken)"
        ]
    }
}
