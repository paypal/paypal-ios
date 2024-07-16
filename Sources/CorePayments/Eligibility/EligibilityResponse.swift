import Foundation

struct EligibilityResponse: Decodable {

    private let fundingEligibility: FundingEligibility
    
    private var isVenmoEligible: Bool {
        fundingEligibility.venmo.eligible
    }
    
    private var isCardEligible: Bool {
        fundingEligibility.card.eligible
    }
    
    private var isPayPalEligible: Bool {
        fundingEligibility.payPal.eligible
    }
    
    private var isPayLaterEligible: Bool {
        fundingEligibility.payLater.eligible
    }
    
    private var isCreditEligible: Bool {
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
