import XCTest
@testable import PayPalUI

class PayPalCreditButton_Tests: XCTestCase {

    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let payPalCreditButton = UIPayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.imageView?.image, PaymentButtonImage.payPalCredit.rawValue)
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIColorFromAssets() {
        let payPalCreditButton = UIPayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.backgroundColor, PaymentButtonColor.darkBlue.rawValue)
    }

    func testInit_whenSwiftUIPayPalCreditButtonCreated_canInit() {
        let action = { }
        let payPalCreditButton = UIPayPalCreditButton { }
        let coordinator = Coordinator(action: action)

        XCTAssertNotNil(payPalCreditButton)
        XCTAssertNotNil(payPalCreditButton.makeCoordinator())
        XCTAssertNotNil(coordinator.onAction(action))
    }
}
