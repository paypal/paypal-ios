import XCTest
@testable import Card

final class Card_Tests: XCTestCase {

    func testCard_givenValidCardExpiry_returnsValidExpiryStringFormat() {
        let cardExpiry = CardExpiry(month: 5, year: 2020)
        XCTAssert(cardExpiry.expiryString == "2020-05")

        let newExpiry = CardExpiry(month: 11, year: 2025)
        XCTAssert(newExpiry.expiryString == "2025-11")
    }

    func testCardEncoding_givenValidCard_returnsValidCardStringFormat() throws {
        let card = Card(
            number: "4032036247327321",
            expiry: CardExpiry(month: 11, year: 2024),
            securityCode: "222"
        )

        let encodedCard = try XCTUnwrap(JSONEncoder().encode(card))
        let cardString = String(data: encodedCard, encoding: .utf8)

        let expectedCardString = """
        {"number":"4032036247327321","security_code":"222","expiry":"2024-11"}
        """

        XCTAssertEqual(cardString, expectedCardString)
    }
}
