import Foundation

public struct EligibilityRequest {

    let intent: EligibilityIntent
    let currency: SupportedCurrencyType
    let enableFunding: [SupportedPaymentMethodsType]
    
    // MARK: - Initializer
    
    public init() {
        self.intent = .CAPTURE
        self.currency = .USD
        self.enableFunding = [.VENMO]
    }
}
