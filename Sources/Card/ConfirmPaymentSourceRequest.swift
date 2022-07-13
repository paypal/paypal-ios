import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// Describes request to confirm a payment source (approve an order)
struct ConfirmPaymentSourceRequest: APIRequest {

    typealias ResponseType = ConfirmPaymentSourceResponse

    let orderID: String
    let pathFormat: String = "/v2/checkout/orders/%@/confirm-payment-source"

    var path: String
    var method: HTTPMethod = .post
    var body: Data?

    private let jsonEncoder = JSONEncoder()

    var headers: [HTTPHeader: String] {

        return [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
        ]
    }

    /// Creates a request to attach a payment source to a specific order.
    /// In order to use this initializer, the `paymentSource` parameter has to
    /// contain the entire dictionary as it exists underneath the `payment_source` key.
    init(
        cardRequest: CardRequest,
        clientID: String
    ) throws {
        var card = cardRequest.card
        if let threeDSecureRequest = cardRequest.threeDSecureRequest {
            let verification = Verification(method: threeDSecureRequest.sca.rawValue)
            card.attributes = Attributes(verification: verification)
        }
        let paymentSource = [ "payment_source": [ "card": card ] ]

        self.orderID = cardRequest.orderID

        path = String(format: pathFormat, orderID)

        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        body = try jsonEncoder.encode(paymentSource)
    }
}
