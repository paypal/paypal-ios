//
//  PayPalWebViewModelConstants.swift
//  Demo
//
//  Created by Anastasia Rodzik on 6/4/26.
//

extension Amount {
    static let defaultAmount: Amount = .init(currencyCode: "USD", value: "10.00")
}

extension Vault {
    static let defaultVault: Vault = .init(storeInVault: "ON_SUCCESS", usageType: "MERCHANT", customerType: "CONSUMER")
}
