import XCTest
@testable import PayPal

class PayPalCreditButton_Tests: XCTestCase {

    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.imageView?.image, PaymentButtonImage.payPalCredit.rawValue)
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIColorFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.backgroundColor, PaymentButtonColor.darkBlue.rawValue)
    }
}
