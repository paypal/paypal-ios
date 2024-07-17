import Foundation

/// Enum representing the possible intents for eligibility.
public enum EligibilityIntent: String {
    
    /// Represents the intent to capture a payment.
    case capture = "CAPTURE"
    
    /// Represents the intent to authorize a payment.
    case authorize = "AUTHORIZE"
}
