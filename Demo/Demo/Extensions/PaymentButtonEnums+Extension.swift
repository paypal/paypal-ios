import PaymentButtons

extension PayPalPayLaterButton.Color {

    public static var allCases: [PayPalPayLaterButton.Color] {
        [.gold, .white, .black, .silver, .blue]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PayPalButton.Color: CaseIterable {

    public static var allCases: [PayPalButton.Color] {
        [.gold, .white, .black, .silver, .blue]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PayPalCreditButton.Color: CaseIterable {

    public static var allCases: [PayPalCreditButton.Color] {
        [.white, .black, .darkBlue]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PaymentButtonEdges: CaseIterable {

    public static var allCases: [PaymentButtonEdges] {
        [.pill, .rounded, .sharp]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.description }
    }
}

extension PaymentButtonSize: CaseIterable {

    public static var allCases: [PaymentButtonSize] {
        [.mini, .regular]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.description }
    }
}

extension PaymentButtonFundingSource: CaseIterable {

    public static var allCases: [PaymentButtonFundingSource] {
        [.payPal, .payLater, .credit]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PayPalButton.Label: CaseIterable {
    
    public static var allCases: [PayPalButton.Label] {
        [
            .none,
            .addMoneyWith,
            .bookWith,
            .buyNowWith,
            .buyWith,
            .checkoutWith,
            .continueWith,
            .contributeWith,
            .orderWith,
            .payWith,
            .payLater,
            .payLaterWith,
            .reloadWith,
            .rentWith,
            .reserveWith,
            .subscribeWith,
            .supportWith,
            .tipWith,
            .topUpWith
        ]
    }
    
    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}
