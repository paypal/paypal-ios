class CardFormatter {

    func formatCardNumber(_ cardNumber: String) -> String {
        /// remove spaces from card string
        var cleanedCardString: String = cardNumber.replacingOccurrences(of: " ", with: "")

        /// gets the card type to know how to format card string
        let cardType = CardType.unknown.getCardType(cleanedCardString)

        /// loops through where the space should be based on the card types indices and inserts a space at the desired index
        cardType.cardNumberIndices.forEach { index in
            if index < cleanedCardString.count {
                let index = cleanedCardString.index(cleanedCardString.startIndex, offsetBy: index)
                cleanedCardString.insert(" ", at: index)
            }
        }
        return cleanedCardString
    }

    func formatExpirationDate( _ expirationDate: String) -> String? {
        /// holder for expiration date
        var currentExpirationDate = expirationDate

        /// ensures that we can delete past the " / " in the string
        if currentExpirationDate.count == 4 {
            currentExpirationDate = String(currentExpirationDate.prefix(2))
            return currentExpirationDate
        }

        /// removes `/` and spaces from expiration date string
        var dateText = currentExpirationDate.replacingOccurrences(of: "/", with: "")
        dateText = dateText.replacingOccurrences(of: " ", with: "")

        /// holder for new date to return
        var newExpirationDate = ""

        /// loops through the date and appends a " / " if after month and the character if entering the year
        for (index, character) in dateText.enumerated() {
            if index == 1 {
                newExpirationDate = "\(newExpirationDate)\(character) / "
            } else {
                newExpirationDate.append(character)
            }
        }
        /// sets the current expiration date to the formatted date
        currentExpirationDate = newExpirationDate
        return currentExpirationDate
    }
}
