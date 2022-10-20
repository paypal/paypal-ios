import XCTest
@testable import PayPalUI

class PayPalButton_Tests: XCTestCase {

    func testInit_whenPayPalButtonCreated_hasUIImageFromAssets() {
        let payPalButton = UIPayPalButton()
        XCTAssertEqual(payPalButton.imageView?.image, PaymentButtonImage.payPal.rawValue)
    }

    func testInit_whenPayPalButtonCreated_hasUIColorFromAssets() {
        let payPalButton = UIPayPalButton()
        XCTAssertEqual(payPalButton.backgroundColor, PaymentButtonColor.gold.rawValue)
    }

    func testInit_whenSwiftUIPayPalButtonCreated_canInit() {
        let action = { }
        let payPalButton = UIPayPalButton { }
        let coordinator = Coordinator(action: action)

        XCTAssertNotNil(payPalButton)
        XCTAssertNotNil(payPalButton.makeCoordinator())
        XCTAssertNotNil(coordinator.onAction(action))
    }
}
