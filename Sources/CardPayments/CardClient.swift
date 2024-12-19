import Foundation
import AuthenticationServices
#if canImport(CorePayments)
import CorePayments
#endif

public class CardClient: NSObject {
    
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

    /// Updates a setup token with a payment method. Performs
    /// 3DS verification if required. If verification is performed, SDK returns a property `didAttemptThreeDSecureAuthentication`.
    /// If `didAttempt3DSecureVerification` is `true`, check verification status with `/v3/vault/setup-token/{id}` in your server.
    /// - Parameters:
    ///   - vaultRequest: The request containing setupTokenID and card
    ///   - completion: A completion block that is invoked when the request is completed. If the request succeeds,
    ///   a `CardVaultResult` with `setupTokenID` and `status` are returned and `error` will be `nil`;
    ///   if it fails, `CardVaultResult will be `nil` and `error` will describe the failure
    public func vault(_ vaultRequest: CardVaultRequest, completion: @escaping (CardVaultResult?, CoreSDKError?) -> Void) {
        analyticsService = AnalyticsService(coreConfig: config, setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("card-payments:vault-wo-purchase:started")
        Task {
            do {
                let result = try await vaultAPI.updateSetupToken(cardVaultRequest: vaultRequest).updateVaultSetupToken

                if result.status == "PAYER_ACTION_REQUIRED",
                let urlString = result.links.first(where: { $0.rel == "approve" })?.href {
                    guard urlString.contains("helios"), let url = URL(string: urlString) else {
                        self.notify3dsVaultFailure(with: CardError.threeDSecureURLError, completion: completion)
                        return
                    }
                    analyticsService?.sendEvent("card-payments:vault-wo-purchase:auth-challenge-required")
                    startVaultThreeDSecureChallenge(url: url, setupTokenID: vaultRequest.setupTokenID, completion: completion)
                } else {
                    let vaultResult = CardVaultResult(setupTokenID: result.id, status: result.status, didAttemptThreeDSecureAuthentication: false)
                    notifyVaultSuccess(for: vaultResult, completion: completion)
                }
            } catch let error as CoreSDKError {
                notifyVaultFailure(with: error, completion: completion)
            } catch {
                notifyVaultFailure(with: CardError.vaultTokenError, completion: completion)
            }
        }
    }

    /// Updates a setup token with a payment method. Performs
    /// 3DS verification if required. If verification is performed, SDK returns a property `didAttemptThreeDSecureAuthentication`.
    /// If `didAttempt3DSecureVerification` is `true`, check verification status with `/v3/vault/setup-token/{id}` in your server.
    /// - Parameters:
    ///   - vaultRequest: The request containing setupTokenID and card
    /// - Returns: `CardVaultResult` if successful
    /// - Throws: A `CoreSDKError` describing failure
    public func vault(_ vaultRequest: CardVaultRequest) async throws -> CardVaultResult {
        try await withCheckedThrowingContinuation { continuation in
            vault(vaultRequest) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    /// Approve an order with a card, which validates buyer's card, and if valid, attaches the card as the payment source to the order.
    /// After the order has been successfully approved, you will need to handle capturing/authorizing the order in your server.
    /// - Parameters:
    ///   - orderId: Order id for approval
    ///   - request: The request containing the card
    ///   - completion: A completion block that is invoked when the request is completed. If the request succeeds,
    ///   a `CardResult` with `orderID` , `status` and `didAttemptThreeDSecureAuthentication` are returned and `error` will be `nil`;
    ///   if it fails, `CardResult will be `nil` and `error` will describe the failure
    public func approveOrder(request: CardRequest, completion: @escaping (CardResult?, CoreSDKError?) -> Void) {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("card-payments:approve-order:started")
        Task {
            do {
                let result = try await checkoutOrdersAPI.confirmPaymentSource(cardRequest: request)
                
                if result.status == "PAYER_ACTION_REQUIRED",
                let url = result.links?.first(where: { $0.rel == "payer-action" })?.href {
                    guard getQueryStringParameter(url: url, param: "flow") == "3ds",
                        url.contains("helios"),
                        let url = URL(string: url) else {
                        self.notify3dsCheckoutFailure(with: CardError.threeDSecureURLError, completion: completion)
                        return
                    }
                
                    analyticsService?.sendEvent("card-payments:approve-order:auth-challenge-required")
                    startThreeDSecureChallenge(url: url, orderId: result.id, completion: completion)
                } else {
                    let cardResult = CardResult(orderID: result.id, status: result.status, didAttemptThreeDSecureAuthentication: false)
                    notifyCheckoutSuccess(for: cardResult, completion: completion)
                }
            } catch let error as CoreSDKError {
                notifyCheckoutFailure(with: error, completion: completion)
            } catch {
                notifyCheckoutFailure(with: CardError.unknownError, completion: completion)
            }
        }
    }

    /// Approve an order with a card, which validates buyer's card, and if valid, attaches the card as the payment source to the order.
    /// After the order has been successfully approved, you will need to handle capturing/authorizing the order in your server.
    /// - Parameters:
    ///   - orderId: Order id for approval
    ///   - request: The request containing the card
    /// - Returns: `CardResult` if successful
    /// - Throws: A `CoreSDKError` describing failure
    public func approveOrder(request: CardRequest) async throws -> CardResult {
        try await withCheckedThrowingContinuation { continuation in
            approveOrder(request: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                }
            }
        }
    }

    private func startThreeDSecureChallenge(
        url: URL,
        orderId: String,
        completion: @escaping (CardResult?, CoreSDKError?) -> Void
    ) {
        
        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    self?.analyticsService?.sendEvent("card-payments:approve-order:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("card-payments:approve-order:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { _, error in
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notify3dsCheckoutCancelWithError(with: CardError.threeDSecureCanceledError, completion: completion)
                        return
                    default:
                        self.notify3dsCheckoutFailure(with: CardError.threeDSecureError(error), completion: completion)
                        return
                    }
                }

                let cardResult = CardResult(orderID: orderId, status: nil, didAttemptThreeDSecureAuthentication: true)
                self.notify3dsCheckoutSuccess(for: cardResult, completion: completion)
            }
        )
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }

    private func startVaultThreeDSecureChallenge(
        url: URL,
        setupTokenID: String,
        completion: @escaping (CardVaultResult?, CoreSDKError?) -> Void
    ) {

        webAuthenticationSession.start(
            url: url,
            context: self,
            sessionDidDisplay: { [weak self] didDisplay in
                if didDisplay {
                    // TODO: analytics for card vault
                    self?.analyticsService?.sendEvent("card-payments:vault-wo-purchase:auth-challenge-presentation:succeeded")
                } else {
                    self?.analyticsService?.sendEvent("card-payments:vault-wo-purchase:auth-challenge-presentation:failed")
                }
            },
            sessionDidComplete: { _, error in
                if let error = error {
                    switch error {
                    case ASWebAuthenticationSessionError.canceledLogin:
                        self.notify3dsVaultCancelWithError(with: CardError.threeDSecureCanceledError, completion: completion)
                        return
                    default:
                        self.notify3dsVaultFailure(with: CardError.threeDSecureError(error), completion: completion)
                        return
                    }
                }

                let cardVaultResult = CardVaultResult(setupTokenID: setupTokenID, status: nil, didAttemptThreeDSecureAuthentication: true)
                self.notify3dsVaultSuccess(for: cardVaultResult, completion: completion)
            }
        )
    }

    private func notifyCheckoutSuccess(for result: CardResult, completion: (CardResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:approve-order:succeeded")
        completion(result, nil)
    }

    private func notify3dsCheckoutSuccess(for result: CardResult, completion: (CardResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:approve-order:auth-challenge-succeeded")
        completion(result, nil)
    }

    private func notifyCheckoutFailure(with error: CoreSDKError, completion: (CardResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:approve-order:failed")
        completion(nil, error)
    }

    private func notify3dsCheckoutFailure(with error: CoreSDKError, completion: (CardResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:approve-order:auth-challenge-failed")
        completion(nil, error)
    }

    private func notify3dsCheckoutCancelWithError(with error: CoreSDKError, completion: (CardResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:approve-order:auth-challenge-canceled")
        completion(nil, error)
    }

    private func notifyVaultSuccess(for vaultResult: CardVaultResult, completion: (CardVaultResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:vault-wo-purchase:succeeded")
        completion(vaultResult, nil)
    }

    private func notify3dsVaultSuccess(for vaultResult: CardVaultResult, completion: (CardVaultResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:vault-wo-purchase:auth-challenge-succeeded")
        completion(vaultResult, nil)
    }

    private func notifyVaultFailure(with vaultError: CoreSDKError, completion: (CardVaultResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:vault-wo-purchase:failed")
        completion(nil, vaultError)
    }

    private func notify3dsVaultFailure(with vaultError: CoreSDKError, completion: (CardVaultResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:vault-wo-purchase:auth-challenge-failed")
        completion(nil, vaultError)
    }

    private func notify3dsVaultCancelWithError(with vaultError: CoreSDKError, completion: (CardVaultResult?, CoreSDKError?) -> Void) {
        analyticsService?.sendEvent("card-payments:vault-wo-purchase:auth-challenge-canceled")
        completion(nil, vaultError)
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
