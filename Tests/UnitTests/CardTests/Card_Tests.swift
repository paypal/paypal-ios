import XCTest
@testable import Card

final class Card_Tests: XCTestCase {

    func testCardEncoding_givenValidCard_returnsValidCardStringFormat() throws {
        let card = Card(
            number: "4032036247327321",
            expirationDate: ExpirationDate(month: 11, year: 2024),
            securityCode: "222"
        )

        let encodedCard = try XCTUnwrap(JSONEncoder().encode(card))
        let cardString = String(data: encodedCard, encoding: .utf8)

        let expectedCardString = """
        {"number":"4032036247327321","security_code":"222","expiry":"2024-11"}
        """

        XCTAssertEqual(cardString, expectedCardString)
    }

    func testCard_givenAnExpirationDate_returnsExpiryStringInCorrectFormat() {
        let cardExpiry = ExpirationDate(month: 5, year: 2020)
        XCTAssert(cardExpiry.expiryString == "2020-05")

        let newExpiry = ExpirationDate(month: 11, year: 2025)
        XCTAssert(newExpiry.expiryString == "2025-11")
    }
}
