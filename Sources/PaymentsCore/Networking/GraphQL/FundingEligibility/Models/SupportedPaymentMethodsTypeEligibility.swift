//
//  SupportedPaymentMethodsTypeEligibility.swift
//  Card
//
//  Created by Andres Pelaez on 19/05/22.
//

struct SupportedPaymentMethodsTypeEligibility: Codable {
    let eligible: Bool
    let reasons: [String]?
}
