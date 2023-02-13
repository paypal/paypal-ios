import XCTest
@testable import CorePayments
@testable import PayPalNativePayments

class PayPalEnvironment_Tests: XCTestCase {

    func testPayPalEnvironment_convertsToPayPalCheckoutEnvironmentCorrectly() {
        let sandbox = Environment.sandbox
        let live = Environment.live

        XCTAssertEqual(sandbox.toNativeCheckoutSDKEnvironment(), .sandbox)
        XCTAssertEqual(live.toNativeCheckoutSDKEnvironment(), .live)
    }
}
