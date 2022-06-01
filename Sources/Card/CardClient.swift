import Foundation
import AuthenticationServices
#if canImport(PaymentsCore)
import PaymentsCore
#endif

public class CardClient {

    public weak var delegate: CardDelegate?

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
    ///   - orderId: Order id for approval
    ///   - request: The request containing the card
    ///   - context: The ASWebAuthenticationPresentationContextProviding protocol conforming ViewController
    /// - Returns: Card result
    /// - Throws: PayPalSDK error if approve order could not complete successfully
    public func approveOrder(
        orderId: String,
        request: CardRequest,
        context: ASWebAuthenticationPresentationContextProviding
    ) async throws {
        let confirmPaymentRequest = try ConfirmPaymentSourceRequest(
            cardRequest: request,
            orderID: orderId,
            clientID: config.clientID
        )
        let (result, _) = try await apiClient.fetch(endpoint: confirmPaymentRequest)

        if let url = result.links?.first(where: { $0.rel == "payer-action" })?.href {
            startThreeDSecureChallenge(url: url, context: context, webAuthenticationSession: WebAuthenticationSession())
        } else {
            let cardResult = CardResult(
                orderID: result.id,
                lastFourDigits: result.paymentSource?.card.lastDigits,
                brand: result.paymentSource?.card.brand,
                type: result.paymentSource?.card.type
            )
            notifySuccess(for: cardResult)
        }
    }

    private func startThreeDSecureChallenge(
        url: String,
        context: ASWebAuthenticationPresentationContextProviding,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        let threeDSUrl = URL(string: url)
                webAuthenticationSession.start(url: threeDSUrl!, context: context) { url, error in
                    if let error = error {
                        print(error)
                    }

                    if let url = url {
                        print(self)
                    }
                }

    }

    private func notifySuccess(for result: CardResult) {
        delegate?.card(self, didFinishWithResult: result)
    }

    private func notifyFailure(with error: CoreSDKError) {
        delegate?.card(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        delegate?.cardDidCancel(self)
    }
}
