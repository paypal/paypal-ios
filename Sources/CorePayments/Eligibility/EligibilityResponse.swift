import Foundation

struct EligibilityResponse: Decodable {

    let fundingEligibility: FundingEligibility
    
    var isVenmoEligible: Bool {
        fundingEligibility.venmo.eligible
    }
    
    var isCardEligible: Bool {
        fundingEligibility.card.eligible
    }
    
    var isPayPalEligible: Bool {
        fundingEligibility.payPal.eligible
    }
    
    var isPayLaterEligible: Bool {
        fundingEligibility.payLater.eligible
    }
    
    var isCreditEligible: Bool {
        fundingEligibility.credit.eligible
    }
    
    var asResult: EligibilityResult {
        EligibilityResult(
            isVenmoEligible: isVenmoEligible,
            isCardEligible: isCardEligible,
            isPayPalEligible: isPayPalEligible,
            isPayLaterEligible: isPayLaterEligible,
            isCreditEligible: isCreditEligible
        )
    }
}

struct FundingEligibility: Decodable {

    let venmo: SupportedPaymentMethodsTypeEligibility
    let card: SupportedPaymentMethodsTypeEligibility
    let payPal: SupportedPaymentMethodsTypeEligibility
    let payLater: SupportedPaymentMethodsTypeEligibility
    let credit: SupportedPaymentMethodsTypeEligibility
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case venmo
        case card
        case payPal = "paypal"
        case payLater = "paylater"
        case credit
    }
}

struct SupportedPaymentMethodsTypeEligibility: Decodable {

    let eligible: Bool
}
