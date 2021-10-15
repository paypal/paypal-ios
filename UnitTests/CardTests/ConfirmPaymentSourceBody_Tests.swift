import Foundation
import XCTest
@testable import PaymentsCore
@testable import Card

final class ConfirmPaymentSourceBody_Tests: XCTestCase {
    
    func testEncoded_returnsConfirmPaymentSourceJSON() {
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )
        
        let sut = ConfirmPaymentSourceBody(card: card)
        let data = sut.encoded()
        let dataAsString = String(data: data!, encoding: .utf8)

        let expected = """
        {"payment_source":{"card":{"number":"4032036247327321","security_code":"222","expiry":"2024-11"}}}
        """
        XCTAssertEqual(expected, dataAsString)
    }
}
