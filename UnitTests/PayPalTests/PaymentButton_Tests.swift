import XCTest
@testable import PayPal

class PaymentButton_Tests: XCTestCase {

    func testInit_whenPayPalButtonCreated_hasUIImageFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.imageView?.image, PaymentButtonImage.payPal.rawValue)
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.imageView?.image, PaymentButtonImage.payPalCredit.rawValue)
    }

    func testInit_whenPayPalButtonCreated_hasUIColorFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.backgroundColor, PaymentButtonColor.gold.rawValue)
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIColorFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.backgroundColor, PaymentButtonColor.darkBlue.rawValue)
    }
}
