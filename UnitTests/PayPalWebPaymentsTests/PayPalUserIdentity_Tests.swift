import XCTest
@testable import PayPalWebPayments

class PayPalUserIdentity_Tests: XCTestCase {

    // MARK: - init(serverSideShopperSessionId:)

    func testInit_withServerSideShopperSessionId_setsSSIDField() {
        let identity = PayPalUserIdentity(serverSideShopperSessionId: "test-ssid-123")

        XCTAssertEqual(identity.serverSideShopperSessionId, "test-ssid-123")
    }

    func testInit_withServerSideShopperSessionId_nilsBuyerHints() {
        let identity = PayPalUserIdentity(serverSideShopperSessionId: "test-ssid-123")

        XCTAssertNil(identity.email)
        XCTAssertNil(identity.phone)
    }

    // MARK: - init(email:phone:)

    func testInit_withEmailAndPhone_setsBothFields() {
        let identity = PayPalUserIdentity(email: "buyer@example.com", phone: "5551234567")

        XCTAssertEqual(identity.email, "buyer@example.com")
        XCTAssertEqual(identity.phone, "5551234567")
    }

    func testInit_withEmailOnly_setsEmailNilsPhone() {
        let identity = PayPalUserIdentity(email: "buyer@example.com")

        XCTAssertEqual(identity.email, "buyer@example.com")
        XCTAssertNil(identity.phone)
    }

    func testInit_withPhoneOnly_setsPhoneNilsEmail() {
        let identity = PayPalUserIdentity(phone: "5551234567")

        XCTAssertNil(identity.email)
        XCTAssertEqual(identity.phone, "5551234567")
    }

    func testInit_withBuyerHints_nilsSSID() {
        let identity = PayPalUserIdentity(email: "buyer@example.com", phone: "5551234567")

        XCTAssertNil(identity.serverSideShopperSessionId)
    }
}
