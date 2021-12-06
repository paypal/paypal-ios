enum Fields {
    case cardNumber
    case expirationDate
    case cvv
}

class CardFormatter {

    func formatCardNumber(_ cardNumber: String) -> String {
        /// remove spaces from card string
        var formattedCardNumber: String = cardNumber.replacingOccurrences(of: " ", with: "")

        /// gets the card type to know how to format card string
        let cardType = CardType.unknown.getCardType(formattedCardNumber)

        /// loops through where the space should be based on the card types indices and inserts a space at the desired index
        cardType.spaceDelimiterIndices.forEach { index in
            if index < formattedCardNumber.count {
                let index = formattedCardNumber.index(formattedCardNumber.startIndex, offsetBy: index)
                formattedCardNumber.insert(" ", at: index)
            }
        }
        return formattedCardNumber
    }

    func formatExpirationDate( _ expirationDate: String) -> String {
        /// holder for the current expiration date
        var formattedDate = expirationDate

        /// if the date count is greater than 2 append " / " after the month to format as MM/YY
        if formattedDate.count > 2 {
            formattedDate.insert(contentsOf: " / ", at: formattedDate.index(formattedDate.startIndex, offsetBy: 2))
        }
        return formattedDate
    }

    func formatFieldWith(_ text: String, field: Fields) -> String {
        switch field {
        case .cardNumber:
            var cardNumberText: String
            let cleanedText = text.replacingOccurrences(of: " ", with: "")
            cardNumberText = String(cleanedText.prefix(CardType.unknown.getCardType(text).maxLength))
            cardNumberText = cardNumberText.filter { ("0"..."9").contains($0) }
            cardNumberText = formatCardNumber(cardNumberText)
            return cardNumberText

        case .expirationDate:
            var expirationDateText: String
            let cleanedText = text.replacingOccurrences(of: " / ", with: "")
            expirationDateText = String(cleanedText.prefix(4))
            expirationDateText = expirationDateText.filter { ("0"..."9").contains($0) }
            expirationDateText = formatExpirationDate(expirationDateText)
            return expirationDateText

        case .cvv:
            var cvvText: String
            cvvText = String(text.prefix(4))
            cvvText = cvvText.filter { ("0"..."9").contains($0) }
            return cvvText
        }
    }
}
