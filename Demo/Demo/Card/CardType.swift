enum CardType {
    case americanExpress, visa, discover, masterCard, unknown

    var spaceDelimiterIndices: [Int] {
        switch self {
        case .americanExpress:
            return [4, 11]
        case .visa:
            return [4, 9, 14]
        case .discover:
            return [4, 9, 14]
        case .masterCard:
            return [4, 9, 14]
        case .unknown:
            return [4, 9, 14]
        }
    }

    var maxLength: Int {
        switch self {
        case .americanExpress:
            return 15
        case .visa:
            return 16
        case .discover:
            return 19
        case .masterCard:
            return 16
        case .unknown:
            return 16
        }
    }

    func getCardType(_ cardNumber: String) -> CardType {
        if cardNumber.starts(with: "34") || cardNumber.starts(with: "37") {
            return .americanExpress
        } else if cardNumber.starts(with: "4") {
            return .visa
        } else if cardNumber.starts(with: "6011") || cardNumber.starts(with: "65") {
            return .discover
        } else if cardNumber.starts(with: "51") || cardNumber.starts(with: "52")
            || cardNumber.starts(with: "53") || cardNumber.starts(with: "54") || cardNumber.starts(with: "55") {
            return .masterCard
        } else {
            return .unknown
        }
    }
}
