import XCTest
import PayPalCheckout
@testable import PayPalNativePayments

class PayPalNativeShippingAddress_Tests: XCTestCase {

    func testInit_convertsFromNXOTypeCorrectly() {
        let nxoShippingAddress = PayPalCheckout.ShippingChangeAddress(
            addressID: "fake-address-id",
            fullName: "fake-full-name",
            adminArea1: "fake-admin-area-1",
            adminArea2: "fake-admin-area-2",
            adminArea3: "fake-admin-area-3",
            adminArea4: "fake-admin-area-4",
            postalCode: "fake-postal-code",
            countryCode: "fake-country-code"
        )
        
        let sut = PayPalNativeShippingAddress(nxoShippingAddress)
        XCTAssertEqual(sut.addressID, "fake-address-id")
        XCTAssertEqual(sut.fullName, "fake-full-name")
        XCTAssertEqual(sut.adminArea1, "fake-admin-area-1")
        XCTAssertEqual(sut.adminArea2, "fake-admin-area-2")
        XCTAssertEqual(sut.adminArea3, "fake-admin-area-3")
        XCTAssertEqual(sut.adminArea4, "fake-admin-area-4")
        XCTAssertEqual(sut.postalCode, "fake-postal-code")
        XCTAssertEqual(sut.countryCode, "fake-country-code")
    }
}
