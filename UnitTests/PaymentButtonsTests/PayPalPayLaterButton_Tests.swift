import XCTest
@testable import PaymentButtons

class PayPalPayLaterButton_Tests: XCTestCase {
    
    // MARK: - PayPalPayLaterButton for UIKit
    
    func testInit_whenPayPalPayLaterButtonCreated_hasDefaultUIValues() {
        let sut = PayPalPayLaterButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.rounded)
        XCTAssertEqual(sut.size, PaymentButtonSize.standard)
        XCTAssertEqual(sut.color, PaymentButtonColor.gold)
        XCTAssertEqual(sut.label, .payLater)
        XCTAssertNil(sut.insets)
    }

    // MARK: - PayPalPayLaterButtonView for SwiftUI
    
    func testMakeCoordinator_whenOnActionIsCalled_executesActionPassedInInitializer() {
        let expectation = expectation(description: "Action is called")
        let sut = PayPalPayLaterButtonView {
            expectation.fulfill()
        }
        let coordinator = sut.makeCoordinator()

        coordinator.onAction(self)
        waitForExpectations(timeout: 1) { error in
            if error != nil {
                XCTFail("Action passed in PayPalPayLaterButtonView was never called.")
            }
        }
    }
}
