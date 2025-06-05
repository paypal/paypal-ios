import XCTest
@testable import PaymentButtons

class PayPalPayLaterButton_Tests: XCTestCase {
    
    // MARK: - PayPalPayLaterButton for UIKit
    
    func testInit_whenPayPalPayLaterButtonCreated_hasDefaultUIValues() {
        let sut = PayPalPayLaterButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.softEdges)
        XCTAssertEqual(sut.color, PaymentButtonColor.blue)
        XCTAssertEqual(sut.label, .payLater)
        XCTAssertNil(sut.insets)
    }

    func testInit_whenWhitePayPalLaterButtonCreated_hasBorderConfiguration() {
        let sut = PayPalPayLaterButton(color: .white)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 1.0)
        let expectedColor = UIColor(hexString: "#555555").cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
    }

    func testInit_whenBluePayPalLaterButtonCreated_hasNoBorderConfiguration() {
        let sut = PayPalPayLaterButton(color: .blue)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 0.0)
        let expectedColor = UIColor.clear.cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
    }

    func testInit_whenBlackPayPalLaterButtonCreated_hasNoBorderConfiguration() {
        let sut = PayPalPayLaterButton(color: .black)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 0.0)
        let expectedColor = UIColor.clear.cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
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
