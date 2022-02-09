import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

public class CardClient {

    private let apiClient: APIClient
    private let config: CoreConfig

    /// Initialize a CardClient to process card payment
    /// - Parameter config: The CoreConfig object
    public init(config: CoreConfig) {
        self.config = config
        self.apiClient = APIClient(environment: config.environment)
    }

    /// For internal use for testing/mocking purpose
    init(config: CoreConfig, apiClient: APIClient) {
        self.config = config
        self.apiClient = apiClient
    }

    /// Approve an order with a card, which validates buyer's card, and if valid, attaches the card as the payment source to the order.
    /// After the order has been successfully approved, you will need to handle capturing/authorizing the order in your server.
    /// - Parameter request: The request containing the card and order id for approval
    /// - Returns: Card result or throws an error
    public func approveOrder(request: CardRequest) async throws -> CardResult {
        let confirmPaymentRequest = try ConfirmPaymentSourceRequest(
            card: request.card,
            orderID: request.orderID,
            clientID: config.clientID
        )
        let (result, _) = try await apiClient.fetch(endpoint: confirmPaymentRequest)

        let cardResult = CardResult(
            orderID: result.id,
            lastFourDigits: result.paymentSource.card.lastDigits,
            brand: result.paymentSource.card.brand,
            type: result.paymentSource.card.type
        )
        return cardResult
    }
}
