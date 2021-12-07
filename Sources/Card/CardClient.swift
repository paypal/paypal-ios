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
    /// - Parameters:
    ///   - cardOrder: The card order to be approved
    ///   - completion: Completion handler for approveOrder, which contains data of the order if success, or an error if failure
    public func approve(_ cardOrder: CardOrder, completion: @escaping (Result<CardOrderApproval, PayPalSDKError>) -> Void) {
        do {
            let confirmPaymentRequest = try ConfirmPaymentSourceRequest(
                card: cardOrder.card,
                orderID: cardOrder.orderID,
                clientID: config.clientID
            )

            apiClient.fetch(endpoint: confirmPaymentRequest) { result, _ in
                switch result {
                case .success(let response):
                    let approval = CardOrderApproval(
                        orderID: response.id,
                        lastFourDigits: response.paymentSource.card.lastDigits,
                        brand: response.paymentSource.card.brand,
                        type: response.paymentSource.card.type
                    )

                    completion(.success(approval))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            // We don't expect this block to ever execute.
            completion(.failure(CardClientError.encodingError))
        }
    }
}
