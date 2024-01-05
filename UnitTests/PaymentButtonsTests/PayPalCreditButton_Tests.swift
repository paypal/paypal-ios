import XCTest
@testable import PaymentButtons

class PayPalCreditButton_Tests: XCTestCase {

    // MARK: - PayPalPayCreditButton for UIKit
    
    func testInit_whenPayPalCreditButtonCreated_hasUIImageFromAssets() {
        let sut = PayPalCreditButton()
        XCTAssertEqual(sut.imageView?.image, UIImage(named: "PayPalCreditLogo"))
    }

    func testInit_whenPayPalCreditButtonCreated_hasDefaultUIValues() {
        let sut = PayPalCreditButton()
        XCTAssertEqual(sut.edges, PaymentButtonEdges.softEdges)
        XCTAssertEqual(sut.size, PaymentButtonSize.collapsed)
        XCTAssertEqual(sut.color, PaymentButtonColor.darkBlue)
        XCTAssertNil(sut.insets)
        XCTAssertNil(sut.label)
    }

    // MARK: - PayPalPayCreditButton.Representable for SwiftUI
    
    func testMakeCoordinator_whenOnActionIsCalled_executesActionPassedInInitializer() {
        let expectation = expectation(description: "Action is called")
        let sut = PayPalCreditButton.Representable {
            expectation.fulfill()
        }
        let coordinator = sut.makeCoordinator()

        coordinator.onAction(self)
        waitForExpectations(timeout: 1) { error  in
            if error != nil {
                XCTFail("Action passed in PayPalCreditButton.Representable was never called.")
            }
        }
    }
}
