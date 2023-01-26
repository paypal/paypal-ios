import XCTest
@testable import PaymentButtons

class PayPalPayLaterButton_Tests: XCTestCase {
    
    // MARK: - PayPalPayLaterButton for UIKit
    
    func testInit_whenPayPalPayLaterButtonCreated_hasDefaultUIValues() {
        let sut = PayPalPayLaterButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.softEdges)
        XCTAssertEqual(sut.size, PaymentButtonSize.collapsed)
        XCTAssertEqual(sut.color, PaymentButtonColor.gold)
        XCTAssertEqual(sut.label, .payLater)
        XCTAssertNil(sut.insets)
    }

    // MARK: - PayPalPayLaterButton.Representable for SwiftUI
    
    func testMakeCoordinator_whenOnActionIsCalled_executesActionPassedInInitializer() {
        let expectation = expectation(description: "Action is called")
        let sut = PayPalPayLaterButton.Representable {
            expectation.fulfill()
        }
        let coordinator = sut.makeCoordinator()

        coordinator.onAction(self)
        waitForExpectations(timeout: 1) { error in
            if error != nil {
                XCTFail("Action passed in PayPalPayLaterButton.Representable was never called.")
            }
        }
    }
}
