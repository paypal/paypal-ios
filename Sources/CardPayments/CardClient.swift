import Foundation
import AuthenticationServices
#if canImport(CorePayments)
import CorePayments
#endif

public class CardClient: NSObject {

    public weak var delegate: CardDelegate?
    public weak var vaultDelegate: CardVaultDelegate?
    
    private let checkoutOrdersAPI: CheckoutOrdersAPI
    private let vaultAPI: VaultPaymentTokensAPI
    
    private let config: CoreConfig
    private let webAuthenticationSession: WebAuthenticationSession
    private var analyticsService: AnalyticsService?

    /// Initialize a CardClient to process card payment
    /// - Parameter config: The CoreConfig object
    public init(config: CoreConfig) {
        self.config = config
        self.checkoutOrdersAPI = CheckoutOrdersAPI(coreConfig: config)
        self.vaultAPI = VaultPaymentTokensAPI(coreConfig: config)
        self.webAuthenticationSession = WebAuthenticationSession()
    }

    /// For internal use for testing/mocking purpose
    init(
        config: CoreConfig,
        checkoutOrdersAPI: CheckoutOrdersAPI,
        vaultAPI: VaultPaymentTokensAPI,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        self.config = config
        self.checkoutOrdersAPI = checkoutOrdersAPI
        self.vaultAPI = vaultAPI
        self.webAuthenticationSession = webAuthenticationSession
    }
    
    @_documentation(visibility: private)
    public func vault(_ vaultRequest: CardVaultRequest) {
        Task {
            do {
                let result = try await vaultAPI.updateSetupToken(cardVaultRequest: vaultRequest).updateVaultSetupToken
                
                // TODO: handle 3DS contingency with helios link & add unit tests
                if let link = result.links.first(where: { $0.rel == "approve" && $0.href.contains("helios") }) {
                    let url = link.href
                    print("3DS url \(url)")
                } else {
                    let vaultResult = CardVaultResult(setupTokenID: result.id, status: result.status)
                    notifyVaultSuccess(for: vaultResult)
                }
            } catch let error as CoreSDKError {
                notifyVaultFailure(with: error)
            } catch {
                notifyVaultFailure(with: CardClientError.vaultTokenError)
            }
        }
    }
           
    /// Approve an order with a card, which validates buyer's card, and if valid, attaches the card as the payment source to the order.
    /// After the order has been successfully approved, you will need to handle capturing/authorizing the order in your server.
    /// - Parameters:
    ///   - orderId: Order id for approval
    ///   - request: The request containing the card
    /// - Returns: Card result
    /// - Throws: PayPalSDK error if approve order could not complete successfully
    public func approveOrder(request: CardRequest) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("card-payments:3ds:started")
        Task {
            do {
                let result = try await checkoutOrdersAPI.confirmPaymentSource(cardRequest: request)
                
                if result.status == "PAYER_ACTION_REQUIRED",
                let url = result.links?.first(where: { $0.rel == "payer-action" })?.href {
                    guard getQueryStringParameter(url: url, param: "flow") == "3ds",
                        url.contains("helios"),
                        let url = URL(string: url) else {
                        self.notifyFailure(with: CardClientError.threeDSecureURLError)
                        return
                    }
                
                    analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:challenge-required")
                    startThreeDSecureChallenge(url: url, orderId: result.id)
                } else {
                    analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:succeeded")
                    
                    let cardResult = CardResult(orderID: result.id, status: result.status, threeDSecureAttempted: false)
                    notifySuccess(for: cardResult)
                }
            } catch let error as CoreSDKError {
                analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:failed")
                notifyFailure(with: error)
            } catch {
                analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:failed")
                notifyFailure(with: CardClientError.unknownError)
            }
        }
    }

    private func startThreeDSecureChallenge(
        url: URL,
        orderId: String
    ) {
        delegate?.cardThreeDSecureWillLaunch(self)
        
        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("card-payments:3ds:challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("card-payments:3ds:challenge-presentation:failed")
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

                let cardResult = CardResult(orderID: orderId, status: nil, threeDSecureAttempted: true)
                self.notifySuccess(for: cardResult)
            }
        )
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func notifySuccess(for result: CardResult) {
        analyticsService?.sendEvent("card-payments:3ds:succeeded")
        delegate?.card(self, didFinishWithResult: result)
    }

    private func notifyFailure(with error: CoreSDKError) {
        analyticsService?.sendEvent("card-payments:3ds:failed")
        delegate?.card(self, didFinishWithError: error)
    }
    
    private func notifyVaultSuccess(for vaultResult: CardVaultResult) {
        vaultDelegate?.card(self, didFinishWithVaultResult: vaultResult)
    }

    private func notifyVaultFailure(with vaultError: CoreSDKError) {
        vaultDelegate?.card(self, didFinishWithVaultError: vaultError)
    }

    private func notifyCancellation() {
        analyticsService?.sendEvent("card-payments:3ds:challenge:user-canceled")
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
