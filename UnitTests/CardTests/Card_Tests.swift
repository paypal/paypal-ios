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
}
