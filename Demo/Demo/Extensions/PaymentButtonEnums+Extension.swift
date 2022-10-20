import PayPalUI

extension UIPayPalPayLaterButton.Color {

    static func allCases() -> [UIPayPalPayLaterButton.Color] {
        [
            UIPayPalPayLaterButton.Color.gold,
            UIPayPalPayLaterButton.Color.white,
            UIPayPalPayLaterButton.Color.black,
            UIPayPalPayLaterButton.Color.silver,
            UIPayPalPayLaterButton.Color.blue
        ]
    }

    static func allCasesAsString() -> [String] {
        allCases().map { $0.rawValue }
    }
}

extension UIPayPalButton.Color {

    static func allCases() -> [UIPayPalButton.Color] {
        [
            UIPayPalButton.Color.gold,
            UIPayPalButton.Color.white,
            UIPayPalButton.Color.black,
            UIPayPalButton.Color.silver,
            UIPayPalButton.Color.blue
        ]
    }

    static func allCasesAsString() -> [String] {
        allCases().map { $0.rawValue }
    }
}

extension UIPayPalCreditButton.Color {

    static func allCases() -> [UIPayPalCreditButton.Color] {
        [
            UIPayPalCreditButton.Color.white,
            UIPayPalCreditButton.Color.black,
            UIPayPalCreditButton.Color.darkBlue
        ]
    }

    static func allCasesAsString() -> [String] {
        allCases().map { $0.rawValue }
    }
}

extension PaymentButtonEdges {

    static func allCases() -> [PaymentButtonEdges] {
        [
            PaymentButtonEdges.hardEdges,
            PaymentButtonEdges.softEdges,
            PaymentButtonEdges.rounded
        ]
    }

    static func allCasesAsString() -> [String] {
        allCases().map { $0.description }
    }
}

extension PaymentButtonSize {

    static func allCases() -> [PaymentButtonSize] {
        [
            PaymentButtonSize.mini,
            PaymentButtonSize.collapsed,
            PaymentButtonSize.expanded,
            PaymentButtonSize.full
        ]
    }

    static func allCasesAsString() -> [String] {
        allCases().map { $0.description }
    }
}

extension PaymentButtonFundingSource {

    static func allCases() -> [PaymentButtonFundingSource] {
        [
            PaymentButtonFundingSource.payPal,
            PaymentButtonFundingSource.payLater,
            PaymentButtonFundingSource.credit
        ]
    }

    static func allCasesAsString() -> [String] {
        PaymentButtonFundingSource.allCases().map { $0.rawValue }
    }
}
