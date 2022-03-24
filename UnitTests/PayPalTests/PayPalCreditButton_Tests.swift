import XCTest
@testable import PayPalNativeCheckout

class PayPalCreditButton_Tests: XCTestCase {

    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.imageView?.image, PaymentButtonImage.payPalCredit.rawValue)
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIColorFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.backgroundColor, PaymentButtonColor.darkBlue.rawValue)
    }

    func testInit_whenSwiftUIPayPalCreditButtonCreated_canInit() {
        let action = { }
        let payPalCreditButton = PayPalCreditButton { }
        let coordinator = Coordinator(action: action)

        XCTAssertNotNil(payPalCreditButton)
        XCTAssertNotNil(payPalCreditButton.makeCoordinator())
        XCTAssertNotNil(coordinator.onAction(action))
    }
}
