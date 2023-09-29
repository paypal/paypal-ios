import Foundation
import CardPayments

extension Card {

    static func createCard(cardNumber: String, expirationDate: String, cvv: String) -> Card {
        let cleanedCardText = cardNumber.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDate.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return Card(number: cleanedCardText, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvv)
    }

    static func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }
}
