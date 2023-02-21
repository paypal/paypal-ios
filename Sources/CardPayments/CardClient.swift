import Foundation
import AuthenticationServices
#if canImport(CorePayments)
import CorePayments
#endif

public class CardClient: NSObject {

    public weak var delegate: CardDelegate?

    private let apiClient: APIClient
    private let config: CoreConfig
    private let webAuthenticationSession: WebAuthenticationSession

    /// Initialize a CardClient to process card payment
    /// - Parameter config: The CoreConfig object
    public init(config: CoreConfig) {
        self.config = config
        self.apiClient = APIClient(coreConfig: config)
        self.webAuthenticationSession = WebAuthenticationSession()
    }

    /// For internal use for testing/mocking purpose
    init(config: CoreConfig, apiClient: APIClient, webAuthenticationSession: WebAuthenticationSession) {
        self.config = config
        self.apiClient = apiClient
        self.webAuthenticationSession = webAuthenticationSession
    }

    /// Approve an order with a card, which validates buyer's card, and if valid, attaches the card as the payment source to the order.
    /// After the order has been successfully approved, you will need to handle capturing/authorizing the order in your server.
    /// - Parameters:
    ///   - orderId: Order id for approval
    ///   - request: The request containing the card
    /// - Returns: Card result
    /// - Throws: PayPalSDK error if approve order could not complete successfully
    public func approveOrder(request: CardRequest) {
        apiClient.sendAnalyticsEvent("card-payments:3ds:started")
        Task {
            do {
                _ = try await apiClient.fetchCachedOrRemoteClientID()
            } catch {
                notifyFailure(with: CorePaymentsError.clientIDNotFoundError)
                return
            }
            
            do {
                let confirmPaymentRequest = try ConfirmPaymentSourceRequest(accessToken: config.accessToken, cardRequest: request)
                let (result) = try await apiClient.fetch(request: confirmPaymentRequest)
                
                if let url: String = result.links?.first(where: { $0.rel == "payer-action" })?.href {
                    apiClient.sendAnalyticsEvent("card-payments:3ds:confirm-payment-source:challenge-required")
                    
                    startThreeDSecureChallenge(url: url, orderId: result.id)
                } else {
                    apiClient.sendAnalyticsEvent("card-payments:3ds:confirm-payment-source:succeeded")
                    
                    let cardResult = CardResult(
                        orderID: result.id,
                        status: result.status,
                        paymentSource: result.paymentSource
                    )
                    notifySuccess(for: cardResult)
                }
            } catch let error as CoreSDKError {
                apiClient.sendAnalyticsEvent("card-payments:3ds:confirm-payment-source:failed")
                notifyFailure(with: error)
            } catch {
            }
        }
    }

    private func startThreeDSecureChallenge(
        url: String,
        orderId: String
    ) {
        guard let threeDSURL = URL(string: url) else {
            self.notifyFailure(with: CardClientError.threeDSecureURLError)
            return
        }
        
        delegate?.cardThreeDSecureWillLaunch(self)
        
        webAuthenticationSession.start(
            url: threeDSURL,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.apiClient.sendAnalyticsEvent("card-payments:3ds:challenge-presentation:succeeded")
                } else {
                    self?.apiClient.sendAnalyticsEvent("card-payments:3ds:challenge-presentation:failed")
                }
            },
            sessionDidComplete: { _, error in
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
        )
    }

    private func getOrderInfo(id orderId: String) {
        let getOrderInfoRequest = GetOrderInfoRequest(
            orderID: orderId,
            accessToken: config.accessToken
        )
        Task {
            do {
                let (result) = try await apiClient.fetch(request: getOrderInfoRequest)
                let cardResult = CardResult(
                    orderID: result.id,
                    status: result.status,
                    paymentSource: result.paymentSource
                )
                self.apiClient.sendAnalyticsEvent("card-payments:3ds:get-order-info:succeeded")
                notifySuccess(for: cardResult)
            } catch let error as CoreSDKError {
                self.apiClient.sendAnalyticsEvent("card-payments:3ds:get-order-info:failed")
                notifyFailure(with: error)
            }
        }
    }

    private func notifySuccess(for result: CardResult) {
        apiClient.sendAnalyticsEvent("card-payments:3ds:succeeded")
        delegate?.card(self, didFinishWithResult: result)
    }

    private func notifyFailure(with error: CoreSDKError) {
        apiClient.sendAnalyticsEvent("card-payments:3ds:failed")
        delegate?.card(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        apiClient.sendAnalyticsEvent("card-payments:3ds:challenge:user-canceled")
        delegate?.cardDidCancel(self)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension CardClient: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }
}
