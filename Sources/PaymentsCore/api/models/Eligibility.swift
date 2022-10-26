import Foundation

/// Class that represents merchant's eligibility for a set of payment methods
struct Eligibility {

    var isVenmoEligible: Bool
    var isPaypalEligible: Bool
    var isPaypalCreditEligible: Bool
    var isPayLaterEligible: Bool
    var isCreditCardEligible: Bool
}
