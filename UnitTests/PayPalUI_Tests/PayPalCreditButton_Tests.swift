import XCTest
@testable import PayPalUI

class PayPalCreditButton_Tests: XCTestCase {

    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let payPalCreditButton = PayPalCreditButton()
        XCTAssertEqual(payPalCreditButton.imageView?.image, UIImage(named: "PayPalCreditLogo"))
    }

    func testInit_whenPayPalCreditButtonCreated_hasDefaultUIValues() {
        let sut = PayPalCreditButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.softEdges)
        XCTAssertEqual(sut.size, PaymentButtonSize.collapsed)
        XCTAssertEqual(sut.color, PaymentButtonColor.darkBlue)
        XCTAssertNil(sut.insets)
    }

    func testMakeCoordinator_whenPayPalCreditButtonRepresentableIsCreated_actionIsSetInCoordinator() {
        let expectation = expectation(description: "Action is called")
        let sut = PayPalCreditButton.Representable {
            expectation.fulfill()
        }
        let coordinator = sut.makeCoordinator()

        coordinator.onAction(self)
        XCTAssertNotNil(sut)
        waitForExpectations(timeout: 1) {error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
