import XCTest
@testable import PayPalUI

class PayPalCreditButton_Tests: XCTestCase {

    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let payPalCreditButton = UIPayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.imageView?.image, UIImage(named: "PayPalCreditLogo"))
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIColorFromAssets() {
        let payPalCreditButton = UIPayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.containerView.backgroundColor, PaymentButtonColor.darkBlue.color)
    }

    func testInit_whenSwiftPayPalCreditButtonCreated_canInit() {
        let action = { }
        let payPalCreditButton = PayPalCreditButton { }
        let coordinator = Coordinator(action: action)

        XCTAssertNotNil(payPalCreditButton)
        XCTAssertNotNil(payPalCreditButton.makeCoordinator())
        XCTAssertNotNil(coordinator.onAction(action))
    }
}
