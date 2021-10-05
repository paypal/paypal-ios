import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// Describes request to confirm a payment source (approve an order)
struct ConfirmPaymentSourceRequest: APIRequest {

    typealias ResponseType = ConfirmPaymentSourceResponse

    let clientID: String
    let orderID: String
    let pathFormat: String = "/v2/checkout/orders/%@/confirm-payment-source"

    var path: String
    var method: HTTPMethod = .post
    var body: Data?

    private let jsonEncoder = JSONEncoder()

    var headers: [HTTPHeader: String] {
        // TODO: Remove clientSecret when this endpoint is updated and can be used with low-scoped token
        // For now, include your clientSecret here and your clientID in CoreConfig to test this request
        let clientSecret = ""
        let encodedClientID = "\(clientID):\(clientSecret)".data(using: .utf8)?.base64EncodedString() ?? ""

        return [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Basic \(encodedClientID)"
        ]
    }

    /// Creates a request to attach a payment source to a specific order.
    /// In order to use this initializer, the `paymentSource` parameter has to
    /// contain the entire dictionary as it exists underneath the `payment_source` key.
    ///
    /// For more information on the expected body structure, see PayPal's internal
    /// [API reference](https://ppaas/api/3719176155270329#apiReference)
    init(
        card: Card,
        orderID: String,
        clientID: String
    ) throws {
        let paymentSource = [ "payment_source": [ "card": card ] ]
        
        self.clientID = clientID
        self.orderID = orderID

        path = String(format: pathFormat, orderID)
        
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        body = try jsonEncoder.encode(paymentSource)
    }
}
