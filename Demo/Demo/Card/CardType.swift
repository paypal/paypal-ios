enum CardType {
    case americanExpress, visa, unknown

    var cardNumberIndices: [Int] {
        switch self {
        case .americanExpress:
            return [4, 11]
        case .visa:
            return [4, 9, 14]
        default:
            return [4, 9, 14]
        }
    }

    var maxLength: Int {
        switch self {
        case .americanExpress:
            return 15
        case .visa:
            return 16
        case .unknown:
            return 16
        }
    }
}
