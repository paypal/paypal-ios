import Foundation


/// The `EligibilityRequest` structure includes the necessary parameters to make an eligibility check request.
public struct EligibilityRequest {

    /// The currency code for the eligibility request.
    let currency: String
    
    /// The intent of the eligibility request.
    let intent: EligibilityIntent
    
    /// An array of supported payment methods for the request. Defaults to `[.VENMO]`.
    let enableFunding: [SupportedPaymentMethodsType]
    
    // MARK: - Initializer
    
    /// Creates an instance of a eligibility request
    /// - Parameters:
    ///    - currency: The currency code for the eligibility request.
    ///    - intent: The intent of the eligibility request.
    public init(currency: String, intent: EligibilityIntent) {
        self.currency = currency
        self.intent = intent
        self.enableFunding = [.VENMO]
    }
}
