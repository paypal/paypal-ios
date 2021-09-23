import XCTest
@testable import Card

final class CardTests: XCTestCase {
    func testCard_expiryStringFormat() {
        let cardExpiry = CardExpiry(month: 5, year: 2020)
        XCTAssert(cardExpiry.expiryString == "2020-05")

        let newExpiry = CardExpiry(month: 11, year: 2025)
        XCTAssert(newExpiry.expiryString == "2025-11")
    }
}
