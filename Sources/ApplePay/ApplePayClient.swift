import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Presents the native Apple Pay sheet and confirms an existing PayPal order.
///
/// The buyer stays in your app. Use the PayPal merchant account you already use for Advanced Checkout.
/// Your server creates the order and later captures it. This client only approves the payment source.
public final class ApplePayClient {

    private let service: ApplePayServicing
    private let authorizer: ApplePayAuthorizing
    private let track: (String, String) -> Void

    /// - Parameter config: The same `CoreConfig` used by the other PayPal clients. Use `.sandbox` while testing.
    public init(config: CoreConfig) {
        self.service = ApplePayAPI(coreConfig: config)
        self.authorizer = PassKitApplePayAuthorizer()
        self.track = { name, orderID in
            AnalyticsService(coreConfig: config, orderID: orderID).sendEvent(name)
        }
    }

    init(
        service: ApplePayServicing,
        authorizer: ApplePayAuthorizing,
        track: @escaping (String, String) -> Void = { _, _ in }
    ) {
        self.service = service
        self.authorizer = authorizer
        self.track = track
    }

    /// Shows the Apple Pay sheet and confirms `request.orderID` with the buyer's Apple Pay token.
    public func approveOrder(request: ApplePayRequest) async throws -> ApplePayResult {
        track("apple-pay:approve-order:started", request.orderID)
        do {
            let result = try await approve(request)
            track("apple-pay:approve-order:succeeded", request.orderID)
            return result
        } catch let error as CoreSDKError {
            let name = ApplePayError.isCanceled(error)
                ? "apple-pay:approve-order:canceled"
                : "apple-pay:approve-order:failed"
            track(name, request.orderID)
            throw error
        } catch {
            track("apple-pay:approve-order:failed", request.orderID)
            throw ApplePayError.unknown
        }
    }

    /// Shows the Apple Pay sheet and confirms `request.orderID` with the buyer's Apple Pay token.
    public func approveOrder(
        request: ApplePayRequest,
        completion: @escaping (Result<ApplePayResult, CoreSDKError>) -> Void
    ) {
        Task {
            do {
                completion(.success(try await approveOrder(request: request)))
            } catch let error as CoreSDKError {
                completion(.failure(error))
            } catch {
                completion(.failure(ApplePayError.unknown))
            }
        }
    }

    private func approve(_ request: ApplePayRequest) async throws -> ApplePayResult {
        let config = try await service.fetchConfig(buyerCountry: request.buyerCountry)
        guard config.isEligible else {
            throw ApplePayError.notEligible
        }

        let paymentRequest = try ApplePayPaymentRequestBuilder.make(request: request, config: config)
        var status: String?
        try await authorizer.authorize(paymentRequest) { authorization in
            status = try await self.service.confirm(orderID: request.orderID, authorization: authorization)
        }
        guard let status else {
            throw ApplePayError.unknown
        }
        return ApplePayResult(orderID: request.orderID, status: status)
    }
}
