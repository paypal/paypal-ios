import XCTest
@testable import PayPal

class PayPalButton_Tests: XCTestCase {

    func testInit_whenPayPalButtonCreated_hasUIImageFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.imageView?.image, PaymentButtonImage.payPal.rawValue)
    }

    func testInit_whenPayPalButtonCreated_hasUIColorFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.backgroundColor, PaymentButtonColor.gold.rawValue)
    }

    func testInit_whenSwiftUIPayPalButtonCreated_canInit() {
        let action = { }
        let payPalButton = PayPalButton.Representable { }
        let coordinator = Coordinator(action: action)

        XCTAssertNotNil(payPalButton)
        XCTAssertNotNil(payPalButton.makeCoordinator())
        XCTAssertNotNil(coordinator.onAction(action))
    }
}
