import XCTest
@testable import CardPayments

class ServiceCard_Tests: XCTestCase {

    func testCardRequest_formatsCorrectly_serviceCard_no_vault() throws {
        let card = Card(
            number: "4111111111111111",
            expirationMonth: "01",
            expirationYear: "2031",
            securityCode: "123",
            cardholderName: "Test Name",
            billingAddress: Address(
                addressLine1: "Test Line 1",
                addressLine2: "Test Line 2",
                locality: "Test City",
                region: "Test State",
                postalCode: "Test Zip",
                countryCode: "Test Country"
            )
        )
        
        let cardRequest = CardRequest(orderID: "order1", card: card, sca: .scaAlways, vault: nil)
        let serviceCard = ServiceCard(cardRequest: cardRequest)
        XCTAssertEqual(card.number, serviceCard.number)
        XCTAssertEqual(card.cardholderName, serviceCard.name)
        XCTAssertEqual(card.securityCode, serviceCard.securityCode)
        XCTAssertEqual(serviceCard.expiry, "\(card.expirationYear)-\(card.expirationMonth)")
        XCTAssertEqual(card.billingAddress, serviceCard.billingAddress)
        XCTAssertEqual(card.number, serviceCard.number)
        XCTAssertEqual(serviceCard.attributes?.verification.method, cardRequest.sca.rawValue)
        XCTAssertNil(serviceCard.attributes?.customer)
        XCTAssertNil(serviceCard.attributes?.vault)
    }
    
    func testCardRequest_formatsCorrectly_serviceCard_vault() throws {
        let card = Card(
            number: "4111111111111111",
            expirationMonth: "01",
            expirationYear: "2031",
            securityCode: "123",
            cardholderName: "Test Name",
            billingAddress: Address(
                addressLine1: "Test Line 1",
                addressLine2: "Test Line 2",
                locality: "Test City",
                region: "Test State",
                postalCode: "Test Zip",
                countryCode: "Test Country"
            )
        )
        
        let vault = Vault(customerID: "test777")
        let cardRequest = CardRequest(orderID: "order1", card: card, sca: .scaAlways, vault: vault)
        let serviceCard = ServiceCard(cardRequest: cardRequest)
        XCTAssertEqual(card.number, serviceCard.number)
        XCTAssertEqual(card.cardholderName, serviceCard.name)
        XCTAssertEqual(card.securityCode, serviceCard.securityCode)
        XCTAssertEqual(serviceCard.expiry, "\(card.expirationYear)-\(card.expirationMonth)")
        XCTAssertEqual(card.billingAddress, serviceCard.billingAddress)
        XCTAssertEqual(card.number, serviceCard.number)
        XCTAssertEqual(serviceCard.attributes?.verification.method, cardRequest.sca.rawValue)
        XCTAssertNotNil(cardRequest.vault?.customerID)
        if let id = cardRequest.vault?.customerID {
            XCTAssertEqual(id, serviceCard.attributes?.customer?.id)
        }
        XCTAssertNotNil(serviceCard.attributes?.vault)
        XCTAssertEqual(serviceCard.attributes?.vault?.storeInVault.rawValue, "ON_SUCCESS")
    }
}
