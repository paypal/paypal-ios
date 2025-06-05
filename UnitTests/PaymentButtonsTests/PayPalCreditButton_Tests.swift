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
        XCTAssertEqual(sut.color, PaymentButtonColor.blue)
        XCTAssertNil(sut.insets)
        XCTAssertNil(sut.label)
    }

    func testInit_whenwhitePayPalButtonCreated_hasBorderConfiguration() {
        let sut = PayPalCreditButton(color: .white)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 1.0)
        let expectedColor = UIColor(hexString: "#555555").cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
    }

    func testInit_whenBluePayPalButtonCreated_hasNoBorderConfiguration() {
        let sut = PayPalCreditButton(color: .blue)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 0.0)
        let expectedColor = UIColor.clear.cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
    }

    func testInit_whenBlackPayPalButtonCreated_hasNoBorderConfiguration() {
        let sut = PayPalCreditButton(color: .black)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 0.0)
        let expectedColor = UIColor.clear.cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
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
