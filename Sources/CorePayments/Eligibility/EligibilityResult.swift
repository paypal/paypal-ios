import Foundation

/// The `EligibilityResult` structure contains the eligibility status for payment methods.
public struct EligibilityResult {
    
    /// A boolean indicating if venmo is eligible.
    public let isVenmoEligible: Bool
    
    /// A boolean indicating if Card is eligible.
    public let isCardEligible: Bool
    
    /// A boolean indicating if PayPal is eligible.
    public let isPayPalEligible: Bool
    
    /// A boolean indicating if PayLater is eligible.
    public let isPayLaterEligible: Bool
    
    /// A boolean indicating if credit is eligible.
    public let isCreditEligible: Bool
}
