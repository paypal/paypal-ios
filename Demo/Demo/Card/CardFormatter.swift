class CardFormatter {

    func formatCardNumber(_ cardNumber: String) -> String {
        /// remove spaces from card string
        var formattedCardNumber: String = cardNumber.replacingOccurrences(of: " ", with: "")

        /// gets the card type to know how to format card string
        let cardType = CardType.unknown.getCardType(formattedCardNumber)

        /// loops through where the space should be based on the card types indices and inserts a space at the desired index
        cardType.spaceDelimiterIndeces.forEach { index in
            if index < formattedCardNumber.count {
                let index = formattedCardNumber.index(formattedCardNumber.startIndex, offsetBy: index)
                formattedCardNumber.insert(" ", at: index)
            }
        }
        return formattedCardNumber
    }

    func formatExpirationDate( _ expirationDate: String) -> String? {
        /// holder for the current expiration date
        var formattedDate = expirationDate

        /// if the date count is greater than 2 append " / " after the month to format as MM/YY
        if formattedDate.count > 2 {
            formattedDate.insert(contentsOf: " / ", at: formattedDate.index(formattedDate.startIndex, offsetBy: 2))
        }

        return formattedDate
    }
}
