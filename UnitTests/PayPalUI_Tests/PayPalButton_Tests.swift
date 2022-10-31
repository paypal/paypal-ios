import XCTest
@testable import PayPalUI

class PayPalButton_Tests: XCTestCase {

    func testInit_whenPayPalButtonCreated_hasUIImageFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.imageView?.image, UIImage(named: "PayPalLogo"))
    }

    func testInit_whenPayPalButtonCreated_hasUIColorFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.containerView.backgroundColor, PaymentButtonColor.gold.color)
    }

    func testInit_whenSwiftPayPalButtonCreated_canInit() {
        let action = { }
        let payPalButton = PayPalButton { }
        let coordinator = Coordinator(action: action)

        XCTAssertNotNil(payPalButton)
        XCTAssertNotNil(payPalButton.makeCoordinator())
        XCTAssertNotNil(coordinator.onAction(action))
    }
}
