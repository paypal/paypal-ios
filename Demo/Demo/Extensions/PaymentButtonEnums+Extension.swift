import PayPalUI

extension PayPalPayLaterButton.Color {

    static func allCases() -> [PayPalPayLaterButton.Color] {
        return [
            PayPalPayLaterButton.Color.gold,
            PayPalPayLaterButton.Color.white,
            PayPalPayLaterButton.Color.black,
            PayPalPayLaterButton.Color.silver,
            PayPalPayLaterButton.Color.blue
        ]
    }

    static func allCasesAsString() -> [String] {
        return allCases().map { $0.rawValue }
    }
}

extension PayPalButton.Color {

    static func allCases() -> [PayPalButton.Color] {
        return [
            PayPalButton.Color.gold,
            PayPalButton.Color.white,
            PayPalButton.Color.black,
            PayPalButton.Color.silver,
            PayPalButton.Color.blue
        ]
    }

    static func allCasesAsString() -> [String] {
        return allCases().map { $0.rawValue }
    }
}

extension PayPalCreditButton.Color {

    static func allCases() -> [PayPalCreditButton.Color] {
        return [
            PayPalCreditButton.Color.white,
            PayPalCreditButton.Color.black,
            PayPalCreditButton.Color.darkBlue
        ]
    }

    static func allCasesAsString() -> [String] {
        return allCases().map { $0.rawValue }
    }
}

extension PaymentButtonEdges {

    static func allCases() -> [PaymentButtonEdges] {
        return [
            PaymentButtonEdges.hardEdges,
            PaymentButtonEdges.softEdges,
            PaymentButtonEdges.rounded
        ]
    }

    static func allCasesAsString() -> [String] {
        return allCases().map { $0.description }
    }
}

extension PaymentButtonSize {

    static func allCases() -> [PaymentButtonSize] {
        return  [
            PaymentButtonSize.mini,
            PaymentButtonSize.collapsed,
            PaymentButtonSize.expanded,
            PaymentButtonSize.full
        ]
    }

    static func allCasesAsString() -> [String] {
        return allCases().map { $0.description }
    }
}

extension PaymentButtonFundingSource {

    static func allCases() -> [PaymentButtonFundingSource] {
        return  [
            PaymentButtonFundingSource.payPal,
            PaymentButtonFundingSource.payLater,
            PaymentButtonFundingSource.credit
        ]
    }

    static func allCasesAsString() -> [String] {
        return PaymentButtonFundingSource.allCases().map { $0.rawValue }
    }
}
