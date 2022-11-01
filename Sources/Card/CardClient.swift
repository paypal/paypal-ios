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
        self.apiClient = APIClient(coreConfig: config)
        
        Task {
            await self.apiClient.sendAnalyticsEvent(name: "test.sample.event")
        }
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
        request: CardRequest,
        context: ASWebAuthenticationPresentationContextProviding
    ) {
        start(request: request, context: context, webAuthenticationSession: WebAuthenticationSession())
    }

    /// Internal function for testing
    func start(
        request: CardRequest,
        context: ASWebAuthenticationPresentationContextProviding,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        Task {
            do {
                let confirmPaymentRequest = try ConfirmPaymentSourceRequest(accessToken: config.accessToken, cardRequest: request)
                let (result, _) = try await apiClient.fetch(endpoint: confirmPaymentRequest)
                if let url: String = result.links?.first(where: { $0.rel == "payer-action" })?.href {
                    delegate?.cardThreeDSecureWillLaunch(self)
                    startThreeDSecureChallenge(url: url, orderId: result.id, context: context, webAuthenticationSession: webAuthenticationSession)
                } else {
                    let cardResult = CardResult(
                        orderID: result.id,
                        status: result.status,
                        paymentSource: result.paymentSource
                    )
                    notifySuccess(for: cardResult)
                }
            } catch let error as CoreSDKError {
                notifyFailure(with: error)
            } catch {
            }
        }
    }

    private func startThreeDSecureChallenge(
        url: String,
        orderId: String,
        context: ASWebAuthenticationPresentationContextProviding,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        if let threeDSUrl = URL(string: url) {
            webAuthenticationSession.start(url: threeDSUrl, context: context) { _, error in
                self.delegate?.cardThreeDSecureDidFinish(self)
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notifyCancellation()
                        return
                    default:
                        self.notifyFailure(with: CardClientError.threeDSecureError(error))
                        return
                    }
                }
                self.getOrderInfo(id: orderId)
            }
        }
    }

    private func getOrderInfo(id orderId: String) {
        let getOrderInfoRequest = GetOrderInfoRequest(
            orderID: orderId,
            accessToken: config.accessToken
        )
        Task {
            do {
                let (result, _) = try await apiClient.fetch(endpoint: getOrderInfoRequest)
                let cardResult = CardResult(
                    orderID: result.id,
                    status: result.status,
                    paymentSource: result.paymentSource
                )
                notifySuccess(for: cardResult)
            } catch let error as CoreSDKError {
                notifyFailure(with: error)
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
