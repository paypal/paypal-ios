import XCTest
@testable import PayPalUI

class PayPalPayLaterButton_Tests: XCTestCase {
    
    func testInit_whenPayPalPayLaterButtonnCreated_hasDefaultUIValues() {
        let sut = PayPalPayLaterButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.softEdges)
        XCTAssertEqual(sut.size, PaymentButtonSize.collapsed)
        XCTAssertEqual(sut.color, PaymentButtonColor.gold)
        XCTAssertEqual(sut.label, .payLater)
        XCTAssertNil(sut.insets)
    }

    func testMakeCoordinator_whenPayPalPayLaterButtonRepresentableIsCreated_actionIsSetInCoordinator() {
        let expectation = expectation(description: "Action is called")
        let sut = PayPalPayLaterButton.Representable {
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
