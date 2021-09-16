import Foundation

/// Describes request to confirm a payment source (approve an order)
public struct ConfirmPaymentSourceRequest: APIRequest {
    public typealias ResponseType = ConfirmPaymentSourceResponse

    let clientID: String
    let orderID: String

    // TODO: Input param for path
    public var path: String = "/v2/checkout/orders/:orderId/confirm-payment-source"
    public var method: HTTPMethod = .post
    public var body: Data?

    public var headers: [HTTPHeader: String] {
        let encodedClientID = "\(clientID):".data(using: .utf8)?.base64EncodedString() ?? ""
        return [
            .accept: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Basic \(encodedClientID)"
        ]
    }

    public init<T: Encodable>(
        paymentSource: T,
        orderID: String,
        clientID: String
    ) throws {
        self.clientID = clientID
        self.orderID = orderID
        body = try JSONEncoder().encode(paymentSource)
    }
}
