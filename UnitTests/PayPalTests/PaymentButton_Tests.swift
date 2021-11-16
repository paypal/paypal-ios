import XCTest
@testable import PayPal

class PaymentButton_Tests: XCTestCase {

    let paymentButton = PaymentButton()

    func testInit_whenPayPalButtonCreated_hasUIImageFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.imageView?.image, paymentButton.getButtonLogo(for: .payPal))
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.imageView?.image, paymentButton.getButtonLogo(for: .payPalCredit))
    }

    func testInit_whenPayPalButtonCreated_hasUIColorFromAssets() {
        let payPalButton = PayPalButton()
        XCTAssertEqual(payPalButton.backgroundColor, paymentButton.getButtonColor(for: .payPal))
    }

    func testInit_whenPayPalCreditButtonCreated_hasUIColorFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.backgroundColor, paymentButton.getButtonColor(for: .payPalCredit))
    }
}
