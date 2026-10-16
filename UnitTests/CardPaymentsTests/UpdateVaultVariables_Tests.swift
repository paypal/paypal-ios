import XCTest
@testable import CardPayments

class UpdateVaultVariables_Tests: XCTestCase {

    func testEncode_includesBillingAddressOnTheCard() throws {
        let variables = UpdateVaultVariables(
            cardVaultRequest: CardVaultRequest(
                card: Card(
                    number: "4111111111111111",
                    expirationMonth: "01",
                    expirationYear: "2028",
                    securityCode: "123",
                    cardholderName: "Jane Smith",
                    billingAddress: Address(
                        addressLine1: "1 Main St",
                        addressLine2: "Apt 2",
                        locality: "San Jose",
                        region: "CA",
                        postalCode: "95131",
                        countryCode: "US"
                    )
                ),
                setupTokenID: "setup-token"
            ),
            clientID: "fake-client-id"
        )

        let json = try encodedJSON(variables)
        XCTAssertEqual(json["clientID"] as? String, "fake-client-id")
        XCTAssertEqual(json["vaultSetupToken"] as? String, "setup-token")

        let paymentSource = json["paymentSource"] as! [String: Any]
        XCTAssertNil(paymentSource["clientID"])
        XCTAssertNil(paymentSource["vaultSetupToken"])

        let card = paymentSource["card"] as! [String: Any]
        XCTAssertEqual(card["number"] as? String, "4111111111111111")
        XCTAssertEqual(card["expiry"] as? String, "2028-01")
        XCTAssertEqual(card["securityCode"] as? String, "123")
        XCTAssertEqual(card["name"] as? String, "Jane Smith")

        let billingAddress = card["billingAddress"] as! [String: Any]
        XCTAssertEqual(billingAddress["addressLine1"] as? String, "1 Main St")
        XCTAssertEqual(billingAddress["addressLine2"] as? String, "Apt 2")
        XCTAssertEqual(billingAddress["adminArea2"] as? String, "San Jose")
        XCTAssertEqual(billingAddress["adminArea1"] as? String, "CA")
        XCTAssertEqual(billingAddress["postalCode"] as? String, "95131")
        XCTAssertEqual(billingAddress["countryCode"] as? String, "US")
    }

    func testEncode_omitsBillingAddressWhenTheCardHasNone() throws {
        let variables = UpdateVaultVariables(
            cardVaultRequest: CardVaultRequest(
                card: Card(
                    number: "4111111111111111",
                    expirationMonth: "01",
                    expirationYear: "2028",
                    securityCode: "123"
                ),
                setupTokenID: "setup-token"
            ),
            clientID: "fake-client-id"
        )

        let json = try encodedJSON(variables)
        let paymentSource = json["paymentSource"] as! [String: Any]
        let card = paymentSource["card"] as! [String: Any]
        XCTAssertNil(card["billingAddress"])
        XCTAssertNil(card["name"])
    }

    private func encodedJSON(_ variables: UpdateVaultVariables) throws -> [String: Any] {
        let data = try JSONEncoder().encode(variables)
        return try JSONSerialization.jsonObject(with: data) as! [String: Any]
    }
}
