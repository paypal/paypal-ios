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
        [.hardEdges, .softEdges, .rounded, .custom(10)]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.description }
    }
}

extension PaymentButtonSize: CaseIterable {

    public static var allCases: [PaymentButtonSize] {
        [.mini, .standard]
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
        [.none, .checkout, .buyNow, .payWith]
    }
    
    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}
