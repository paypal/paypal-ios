
struct SupportedPaymentMethodsTypeEligibility: Codable {
    let eligible: Bool
    let reasons: [String]?
}
