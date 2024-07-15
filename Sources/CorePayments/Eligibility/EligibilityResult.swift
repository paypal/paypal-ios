import Foundation

public struct EligibilityResult {
    
    public let isVenmoEligible: Bool
    public let isCardEligible: Bool
    public let isPayPalEligible: Bool
    public let isPayLaterEligible: Bool
    public let isCreditEligible: Bool
}
