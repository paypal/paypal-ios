import XCTest
@testable import PaymentsCore
@testable import PayPal
import PayPalCheckout

final class PayPalUIDelegate_Tests: XCTestCase, PayPalUIDelegate {

    var didApprove = false
    var didReceiveError = false
    var didCancel = false

    override func setUp() {
        super.setUp()
        didApprove = false
        didReceiveError = false
        didCancel = false
    }

    func testCreateOrderCallbackSetCorrectly() throws {
        let paypalCheckoutConfig = try setupPayPalCheckoutConfig()
        XCTAssertNotNil(paypalCheckoutConfig.createOrder)
    }

    func testDidCancelInvokedCorrectly_whenPayPalCheckoutOnCancelIsInvoked() throws {
        let paypalCheckoutConfig = try setupPayPalCheckoutConfig()
        let onCancel = try XCTUnwrap(paypalCheckoutConfig.onCancel)
        onCancel()
        XCTAssertTrue(didCancel)
    }

    func paypal(_ paypal: PayPalUI, didApproveWith data: PayPalResult) {
        didApprove = true
    }
    
    func paypal(_ paypal: PayPalUI, didReceiveError error: PayPalSDKError) {
        didReceiveError = true
    }
    
    func paypalDidCancel(_ paypal: PayPalUI) {
        didCancel = true
    }

    private func setupPayPalCheckoutConfig() throws -> CheckoutConfig {
        let config = CoreConfig(clientID: "", environment: .sandbox, returnUrl: "")
        let paypalPaysheet = PayPalPaysheet(config: config)
        paypalPaysheet.delegate = self

        return try paypalPaysheet.setPayPalCheckoutConfig(orderID: "")
    }
}
