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
        fundingEligibility.paypal.eligible
    }
    
    var isPayLaterEligible: Bool {
        fundingEligibility.paylater.eligible
    }
    
    var isCreditEligible: Bool {
        fundingEligibility.credit.eligible
    }
    
    var asResult: EligibilityResult {
        .init(
            isVenmoEligible: isVenmoEligible,
            isCardEligible: isCardEligible,
            isPayPalEligible: isPayPalEligible,
            isPayLaterEligible: isPayLaterEligible,
            isCreditEligible: isCreditEligible
        )
    }
}

struct FundingEligibility: Codable {

    let venmo: SupportedPaymentMethodsTypeEligibility
    let card: SupportedPaymentMethodsTypeEligibility
    let paypal: SupportedPaymentMethodsTypeEligibility
    let paylater: SupportedPaymentMethodsTypeEligibility
    let credit: SupportedPaymentMethodsTypeEligibility
}

struct SupportedPaymentMethodsTypeEligibility: Codable {

    let eligible: Bool
    let reasons: [String]?
}
