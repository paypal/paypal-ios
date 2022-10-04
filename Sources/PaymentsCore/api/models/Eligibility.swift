import Foundation

/// Class that represents merchant's eligiblity for a set of payment methods
public struct Eligibility {

    var isVenmoEligible: Bool
    var isPaypalEligible: Bool
    var isPaypalCreditEligible: Bool
    var isPayLaterEligible: Bool
    var isCreditCardEligible: Bool
}
