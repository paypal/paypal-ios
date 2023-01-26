import XCTest
@testable import PaymentButtons

class PayPalButton_Tests: XCTestCase {

    // MARK: - PayPalButton for UIKit
    
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

    // MARK: - PayPalButton.Representable for SwiftUI
    
    func testMakeCoordinator_whenOnActionIsCalled_executesActionPassedInInitializer() {
        let expectation = expectation(description: "Action is called")
        let sut = PayPalButton.Representable {
            expectation.fulfill()
        }
        let coordinator = sut.makeCoordinator()

        coordinator.onAction(self)
        waitForExpectations(timeout: 1) { error  in
            if error != nil {
                XCTFail("Action passed in PayPalButton.Representable was never called.")
            }
        }
    }
}
