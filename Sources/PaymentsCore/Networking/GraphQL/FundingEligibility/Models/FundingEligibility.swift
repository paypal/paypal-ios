//
//  FundingEligibility.swift
//  Card
//
//  Created by Andres Pelaez on 19/05/22.
//

struct FundingEligibility: Codable {
    let venmo: SupportedPaymentMethodsTypeEligibility
    let card: SupportedPaymentMethodsTypeEligibility
    let paypal: SupportedPaymentMethodsTypeEligibility
    let payLater: SupportedPaymentMethodsTypeEligibility
    let credit: SupportedPaymentMethodsTypeEligibility
}
