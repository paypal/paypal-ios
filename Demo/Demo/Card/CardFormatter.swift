class CardFormatter {

    func formatCardNumber(_ newCardNumber: String, previousCardNumber: String = "") -> String {
        if newCardNumber.count < previousCardNumber.count {
            return newCardNumber
        }

        var cardString: String = newCardNumber.replacingOccurrences(of: " ", with: "")

        let cardType = CardType.unknown.getCardType(cardString)

        if previousCardNumber.count == cardType.maxLength + cardType.cardNumberIndices.count {
            return previousCardNumber
        } else {
            cardType.cardNumberIndices.forEach { index in
                if index < cardString.count {
                    let index = cardString.index(cardString.startIndex, offsetBy: index)
                    cardString.insert(" ", at: index)
                }
            }
            return cardString
        }
    }

    func formatExpirationDate( _ newExpirationDate: String, previousExpirationDate: String = "") -> String? {
        var currentExpirationDate = newExpirationDate

        if currentExpirationDate.count == 4 {
            currentExpirationDate = String(currentExpirationDate.prefix(2))
            return currentExpirationDate
        }

        var dateText = currentExpirationDate.replacingOccurrences(of: "/", with: "")
        dateText = dateText.replacingOccurrences(of: " ", with: "")

        var newExpirationDate = ""
        for (index, character) in dateText.enumerated() {
            if index == 1 {
                newExpirationDate = "\(newExpirationDate)\(character) / "
            } else {
                newExpirationDate.append(character)
            }
        }
        currentExpirationDate = newExpirationDate
        return currentExpirationDate
    }
}
