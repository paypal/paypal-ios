import Foundation
@testable import CardPayments
@testable import CorePayments

class MockCheckoutOrderConfirmingAPI: CheckoutOrderConfirming {

    var stubConfirmResponse: ConfirmPaymentSourceResponse?
    var stubError: Error?
    private(set) var confirmPaymentSourceCallCount = 0
    var capturedCardRequest: CardRequest?

    func confirmPaymentSource(cardRequest: CardRequest) async throws -> ConfirmPaymentSourceResponse {
        confirmPaymentSourceCallCount += 1
        capturedCardRequest = cardRequest

        if let stubError {
            throw stubError
        }

        if let stubConfirmResponse {
            return stubConfirmResponse
        }

        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
