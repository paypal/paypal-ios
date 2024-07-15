import Foundation

/// The `EligibilityRequest` structure includes the necessary parameters to make an eligibility check request.
public struct EligibilityRequest {

    // MARK: - Internal Properties
    
    /// The currency code for the eligibility request.
    let currencyCode: String
    
    /// The intent of the eligibility request.
    let intent: EligibilityIntent
    
    /// An array of supported payment methods for the request. Defaults to `[.VENMO]`.
    let enableFunding: [SupportedPaymentMethodsType]
    
    // MARK: - Initializer
    
    /// Creates an instance of a eligibility request
    /// - Parameters:
    ///    - currencyCode: The currency code for the eligibility request.
    ///    - intent: The intent of the eligibility request.
    public init(currencyCode: String, intent: EligibilityIntent) {
        self.currencyCode = currencyCode
        self.intent = intent
        self.enableFunding = [.VENMO]
    }
}
