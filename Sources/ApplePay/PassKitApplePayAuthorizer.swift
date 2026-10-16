import PassKit

protocol ApplePayAuthorizing: AnyObject {
    func authorize(
        _ request: PKPaymentRequest,
        confirm: @escaping (ApplePayAuthorization) async throws -> Void
    ) async throws
}

/// Presents the system Apple Pay sheet and confirms with PayPal before the sheet reports success.
final class PassKitApplePayAuthorizer: NSObject, ApplePayAuthorizing {

    private var continuation: CheckedContinuation<Void, Error>?
    private var controller: PKPaymentAuthorizationController?
    private var confirmPayment: ((ApplePayAuthorization) async throws -> Void)?
    private var authorizationError: Error?
    private var didAuthorize = false

    func authorize(
        _ request: PKPaymentRequest,
        confirm: @escaping (ApplePayAuthorization) async throws -> Void
    ) async throws {
        guard PKPaymentAuthorizationController.canMakePayments(usingNetworks: request.supportedNetworks) else {
            throw ApplePayError.unavailable
        }

        confirmPayment = confirm
        authorizationError = nil
        didAuthorize = false

        let paymentController = PKPaymentAuthorizationController(paymentRequest: request)
        paymentController.delegate = self
        controller = paymentController

        let presented = await present(paymentController)
        guard presented else {
            throw ApplePayError.presentationFailed
        }

        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    private func present(_ controller: PKPaymentAuthorizationController) async -> Bool {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                controller.present { presented in
                    continuation.resume(returning: presented)
                }
            }
        }
    }
}

extension PassKitApplePayAuthorizer: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss { [weak self] in
            guard let self else {
                return
            }
            let continuation = self.continuation
            self.continuation = nil
            self.controller = nil
            if let authorizationError = self.authorizationError {
                continuation?.resume(throwing: authorizationError)
            } else if self.didAuthorize {
                continuation?.resume()
            } else {
                continuation?.resume(throwing: ApplePayError.canceled)
            }
        }
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        let confirmPayment = self.confirmPayment
        Task {
            do {
                let authorization = try ApplePayPaymentMapper.authorization(from: payment)
                try await confirmPayment?(authorization)
                await MainActor.run { self.didAuthorize = true }
                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            } catch {
                await MainActor.run { self.authorizationError = error }
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            }
        }
    }
}
