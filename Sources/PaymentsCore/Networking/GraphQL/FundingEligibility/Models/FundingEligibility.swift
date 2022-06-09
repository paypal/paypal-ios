
struct FundingEligibility: Codable {
    let venmo: SupportedPaymentMethodsTypeEligibility
    let card: SupportedPaymentMethodsTypeEligibility
    let paypal: SupportedPaymentMethodsTypeEligibility
    let paylater: SupportedPaymentMethodsTypeEligibility
    let credit: SupportedPaymentMethodsTypeEligibility
}
