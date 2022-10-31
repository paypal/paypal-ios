import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// Describes request to confirm a payment source (approve an order)
struct ConfirmPaymentSourceRequest: APIRequest {

    private let orderID: String
    private let pathFormat: String = "/v2/checkout/orders/%@/confirm-payment-source"
    private let accessToken: String
    private let jsonEncoder = JSONEncoder()

    /// Creates a request to attach a payment source to a specific order.
    /// In order to use this initializer, the `paymentSource` parameter has to
    /// contain the entire dictionary as it exists underneath the `payment_source` key.
    init(
        accessToken: String,
        cardRequest: CardRequest
    ) throws {
        var card = cardRequest.card
        if let threeDSecureRequest = cardRequest.threeDSecureRequest {
            let verification = Verification(method: threeDSecureRequest.sca.rawValue)
            card.attributes = Attributes(verification: verification)
        }
        let paymentSource = [ "payment_source": [ "card": card ] ]

        self.orderID = cardRequest.orderID
        self.accessToken = accessToken

        path = String(format: pathFormat, orderID)

        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        body = try jsonEncoder.encode(paymentSource)
        
        // TODO - The complexity in this `init` signals to reconsider our use/design of the `APIRequest` protocol.
        // Existing pattern doesn't provide clear, testable interface for encoding JSON POST bodies.
    }

    // MARK: - APIRequest

    typealias ResponseType = ConfirmPaymentSourceResponse

    var path: String
    var method: HTTPMethod = .post
    var body: Data?

    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json", .acceptLanguage: "en_US",
            .authorization: "Bearer \(accessToken)"
        ]
    }
}
