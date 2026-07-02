import XCTest
@testable import PayPalWebPayments

class PayPalUserIdentity_Tests: XCTestCase {

    // MARK: - .serverSideShopperSession

    func testServerSideShopperSession_storesSessionID() {
        let identity = PayPalUserIdentity.serverSideShopperSession(serverSideShopperSessionId: "test-ssid-123")

        guard case .serverSideShopperSession(let ssid) = identity else {
            XCTFail("Expected .serverSideShopperSession case")
            return
        }
        XCTAssertEqual(ssid, "test-ssid-123")
    }

    // MARK: - .email

    func testEmail_withEmailAndPhone_storesBothValues() {
        let identity = PayPalUserIdentity.emailPhone(email: "buyer@example.com", phone: "5551234567")

        guard case let .emailPhone(email, phone) = identity else {
            XCTFail("Expected .email case")
            return
        }
        XCTAssertEqual(email, "buyer@example.com")
        XCTAssertEqual(phone, "5551234567")
    }

    func testEmail_withEmailOnly_storesNilPhone() {
        let identity = PayPalUserIdentity.emailPhone(email: "buyer@example.com", phone: nil)

        guard case let .emailPhone(email, phone) = identity else {
            XCTFail("Expected .email case")
            return
        }
        XCTAssertEqual(email, "buyer@example.com")
        XCTAssertNil(phone)
    }

    func testEmail_withPhoneOnly_storesNilEmail() {
        let identity = PayPalUserIdentity.emailPhone(email: nil, phone: "5551234567")

        guard case let .emailPhone(email, phone) = identity else {
            XCTFail("Expected .email case")
            return
        }
        XCTAssertNil(email)
        XCTAssertEqual(phone, "5551234567")
    }

    // MARK: - .none

    func testNone_isNoneCase() {
        let identity = PayPalUserIdentity.anonymous

        guard case .anonymous = identity else {
            XCTFail("Expected .none case")
            return
        }
    }
}
