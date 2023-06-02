struct FundingEligibilityResponse: Codable {

    let fundingEligibility: FundingEligibility
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
