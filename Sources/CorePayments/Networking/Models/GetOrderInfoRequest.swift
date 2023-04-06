/// :nodoc:
public struct GetOrderInfoRequest: APIRequest {

    private let pathFormat: String = "v2/checkout/orders/%@"
    private let accessToken: String

    public init(orderID: String, accessToken: String) {
        self.accessToken = accessToken
        path = String(format: pathFormat, orderID)
    }

    // MARK: - APIRequest

    public typealias ResponseType = GetOrderInfoResponse

    public var path: String
    public var method: HTTPMethod = .get

    public var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer \(accessToken)"
        ]
    }
}
