//
//  PaymentButtonFundingSource.swift
//  PayPalUI
//
//  Created by Jose Noriega on 02/05/2022.
//

import Foundation

/// The funding source to be used when checkout with PaymentButton
@objc(PPCPaymentButtonFundingSource)
public enum PaymentButtonFundingSource: Int, CaseIterable, CustomStringConvertible {
    case payPal
    case payLater
    case credit

    public var description: String {
        switch self {
        case .payPal:
            return "PayPal"

        case .payLater:
            return "Pay Later"

        case .credit:
            return "Credit"
        }
    }
}
