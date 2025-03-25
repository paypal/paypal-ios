import XCTest
@testable import PaymentButtons

class CardButton_Tests: XCTestCase {

    // MARK: - CardButton for UIKit

    func testInit_whenCardButtonCreated_hasUIImageFromAssets() {
        let sut = CardButton()
        XCTAssertEqual(sut.imageView?.image, UIImage(named: "card-black"))
    }

    func testInit_whenPayPalButtonCreated_hasDefaultUIValuess() {
        let sut = CardButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.softEdges)
        XCTAssertEqual(sut.size, PaymentButtonSize.collapsed)
        XCTAssertEqual(sut.color, PaymentButtonColor.black)
        XCTAssertEqual(sut.label, PaymentButtonLabel.card)
        XCTAssertNil(sut.insets)
    }

    // MARK: - PayPalButton.Representable for SwiftUI

    func testMakeCoordinator_whenOnActionIsCalled_executesActionPassedInInitializer() {
        let expectation = expectation(description: "Action is called")
        let sut = CardButton.Representable {
            expectation.fulfill()
        }
        let coordinator = sut.makeCoordinator()

        coordinator.onAction(self)
        waitForExpectations(timeout: 1) { error  in
            if error != nil {
                XCTFail("Action passed in CardButton.Representable was never called.")
            }
        }
    }
}
