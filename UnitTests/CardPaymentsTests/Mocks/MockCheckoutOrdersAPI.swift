import Foundation
@testable import CardPayments
@testable import CorePayments

class MockCheckoutOrdersAPI: CheckoutOrdersAPI {
    
    var stubConfirmResponse: ConfirmPaymentSourceResponse?
    var stubError: Error?
    
    var capturedCardRequest: CardRequest?

    override func confirmPaymentSource(cardRequest: CardRequest) async throws -> ConfirmPaymentSourceResponse {
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
