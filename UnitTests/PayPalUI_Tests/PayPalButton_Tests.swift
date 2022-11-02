import XCTest
@testable import PayPalUI

class PayPalButton_Tests: XCTestCase {

    func testInit_whenPayPalButtonCreated_hasUIImageFromAssets() {
        let sut = PayPalButton()
        XCTAssertEqual(sut.imageView?.image, UIImage(named: "PayPalLogo"))
    }

    func testInit_whenPayPalButtonCreated_hasDefaultUIValuess() {
        let sut = PayPalButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.softEdges)
        XCTAssertEqual(sut.size, PaymentButtonSize.collapsed)
        XCTAssertEqual(sut.color, PaymentButtonColor.gold)
        XCTAssertNil(sut.label)
        XCTAssertNil(sut.insets)
    }

    func testMakeCoordinator_whenPayPalButtonRepresentableIsCreated_actionIsSetInCoordinator() {
        let expectation = expectation(description: "Action is called")
        let sut = PayPalButton.Representable {
            expectation.fulfill()
        }
        let coordinator = sut.makeCoordinator()

        coordinator.onAction(self)
        XCTAssertNotNil(sut)
        waitForExpectations(timeout: 1)
    }
}
