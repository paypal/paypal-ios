import Foundation
import XCTest
@testable import CorePayments
@testable import CardPayments
@testable import TestShared

class ConfirmPaymentSourceRequest_Tests: XCTestCase {
    
    // TODO: - Move to SDK wrapper on JSONEncoder for use in tests & NetworkingClient
    let encoder = JSONEncoder()
    
    override func setUp() {
        super.setUp()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    func testEncode_properlyFormatsJSON() throws {
        let sut = ConfirmPaymentSourceRequest(
            cardRequest: CardRequest(
                orderID: "some-order-id",
                card: Card(
                    number: "some-number",
                    expirationMonth: "some-month",
                    expirationYear: "some-year",
                    securityCode: "some-code",
                    cardholderName: "some-name",
                    billingAddress: Address(
                        addressLine1: "some-line-1",
                        addressLine2: "some-line-2",
                        locality: "some-locality",
                        region: "some-region",
                        postalCode: "some-postal-code",
                        countryCode: "some-country"
                    )
                ),
                sca: .scaAlways
            )
        )
        
        let data = try encoder.encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]
            
        XCTAssertEqual(json?["application_context"]?["return_url"] as! String, "sdk.ios.paypal://card/success")
        XCTAssertEqual(json?["application_context"]?["cancel_url"] as! String, "sdk.ios.paypal://card/cancel")
        
        let cardLevel = json?["payment_source"]?["card"] as! [String: Any]
        XCTAssertEqual(cardLevel["number"] as! String, "some-number")
        XCTAssertEqual(cardLevel["expiry"] as! String, "some-year-some-month")
        XCTAssertEqual(cardLevel["name"] as! String, "some-name")
        
        let billingAddressLevel = cardLevel["billing_address"] as! [String: Any]
        XCTAssertEqual(billingAddressLevel["address_line_1"] as! String, "some-line-1")
        XCTAssertEqual(billingAddressLevel["address_line_2"] as! String, "some-line-2")
        XCTAssertEqual(billingAddressLevel["admin_area_1"] as! String, "some-region")
        XCTAssertEqual(billingAddressLevel["admin_area_2"] as! String, "some-locality")
        XCTAssertEqual(billingAddressLevel["postal_code"] as! String, "some-postal-code")
        XCTAssertEqual(billingAddressLevel["country_code"] as! String, "some-country")

        let attributesLevel = cardLevel["attributes"] as! [String: [String: Any]]
        XCTAssertEqual(attributesLevel["verification"]?["method"] as! String, "SCA_ALWAYS")
    }
    
    func testEncode_withoutBillingAddress_properlyFormatsJSON() throws {
        let sut = ConfirmPaymentSourceRequest(
            cardRequest: CardRequest(
                orderID: "some-order-id",
                card: Card(
                    number: "some-number",
                    expirationMonth: "some-month",
                    expirationYear: "some-year",
                    securityCode: "some-code",
                    cardholderName: "some-name"
                ),
                sca: .scaAlways
            )
        )
        
        let data = try encoder.encode(sut)
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]]
            
        XCTAssertEqual(json?["application_context"]?["return_url"] as! String, "sdk.ios.paypal://card/success")
        XCTAssertEqual(json?["application_context"]?["cancel_url"] as! String, "sdk.ios.paypal://card/cancel")
        
        let cardLevel = json?["payment_source"]?["card"] as! [String: Any]
        XCTAssertEqual(cardLevel["number"] as! String, "some-number")
        XCTAssertEqual(cardLevel["expiry"] as! String, "some-year-some-month")
        XCTAssertEqual(cardLevel["name"] as! String, "some-name")
        
        XCTAssertNil(cardLevel["billing_address"])

        let attributesLevel = cardLevel["attributes"] as! [String: [String: Any]]
        XCTAssertEqual(attributesLevel["verification"]?["method"] as! String, "SCA_ALWAYS")
    }
}
