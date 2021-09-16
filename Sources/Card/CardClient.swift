import Foundation
import PaymentsCore

public class CardClient {
    let apiClient: APIClient
    let config: CoreConfig
    
    public init(config: CoreConfig) {
        self.config = config
        self.apiClient = APIClient(environment: config.environment)
    }

    public func approveOrder(orderID: String, card: Card, completion: (Result<OrderData, Error>) -> Void) {
        let cardDictionary = ["payment_source": ["card": card]]

        do {
            let confirmPaymentRequest = try ConfirmPaymentSourceRequest(
                paymentSource: cardDictionary,
                orderID: orderID,
                clientID: config.clientID
            )

            apiClient.fetch(endpoint: confirmPaymentRequest) { result, _ in
                switch result {
                case .success(let response):
                    let orderData = OrderData(orderID: response.id, status: response.status)
                    completion(.success(orderData))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        catch {
            completion(.failure(CoreError.encodingError(error)))
        }
    }
}


// let data = ["payment_source": ["card": card]]
