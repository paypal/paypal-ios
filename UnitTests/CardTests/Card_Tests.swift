import XCTest
@testable import Card

final class Card_Tests: XCTestCase {
    func testCard_setsProperExpiryStringFormat() {
        let card = Card(
            number: "4111111111111111",
            expirationMonth: "01",
            expirationYear: "2031",
            securityCode: "123"
        )
        
        XCTAssertEqual(card.expiry, "2031-01")
    }

    func testCard_encodedToCorrectFormat() throws {
        let card = Card(
            number: "4111111111111111",
            expirationMonth: "01",
            expirationYear: "2031",
            securityCode: "123",
            cardHolderName: "Test Name",
            billingAddress: Address(
                addressLine1: "Test Line 1",
                addressLine2: "Test Line 2",
                locality: "Test City",
                region: "Test State",
                postalCode: "Test Zip",
                countryCode: "Test Country"
            )
        )

        let encodedCard = try JSONEncoder().encode(card)
        let cardJSON = String(data: encodedCard, encoding: .utf8)

        let expectedCardJSON = """
        {"number":"4111111111111111","billingAddress":{"admin_area_2":"Test City","addressLine1":"Test Line 1","countryCode":"Test Country","addressLine2":"Test Line 2","admin_area_1":"Test State","postalCode":"Test Zip"},"securityCode":"123","name":"Test Name","expiry":"2031-01"}
        """

        XCTAssertEqual(cardJSON, expectedCardJSON)
    }
}
