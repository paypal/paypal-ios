import PaymentButtons

extension PayPalPayLaterButton.Color {

    public static var allCases: [PayPalPayLaterButton.Color] {
        [.gold, .white, .black, .silver, .blue]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PayPalButton.Color {

    public static var allCases: [PayPalButton.Color] {
        [.gold, .white, .black, .silver, .blue]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PayPalCreditButton.Color {

    public static var allCases: [PayPalCreditButton.Color] {
        [.white, .black, .darkBlue]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PaymentButtonEdges {

    public static var allCases: [PaymentButtonEdges] {
        [.hardEdges, .softEdges, .rounded, .custom(10)]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.description }
    }
}

extension PaymentButtonSize {

    public static var allCases: [PaymentButtonSize] {
        [.mini, .collapsed, .expanded, .full]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.description }
    }
}

extension PaymentButtonFundingSource {

    public static var allCases: [PaymentButtonFundingSource] {
        [.payPal, .payLater, .credit]
    }

    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}

extension PayPalButton.Label {

    public static var allCases: [PayPalButton.Label] {
        [.none, .checkout, .buyNow, .payWith]
    }
    
    static func allCasesAsString() -> [String] {
        Self.allCases.map { $0.rawValue }
    }
}
