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
        XCTAssertEqual(sut.color, PaymentButtonColor.blue)
        XCTAssertNil(sut.label)
        XCTAssertNil(sut.insets)
    }

    func testInit_whenwhitePayPalButtonCreated_hasBorderConfiguration() {
        let sut = PayPalButton(color: .white)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 1.0)
        let expectedColor = UIColor(hexString: "#555555").cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
    }

    func testInit_whenBluePayPalButtonCreated_hasNoBorderConfiguration() {
        let sut = PayPalButton(color: .blue)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 0.0)
        let expectedColor = UIColor.clear.cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
    }

    func testInit_whenBlackPayPalButtonCreated_hasNoBorderConfiguration() {
        let sut = PayPalButton(color: .black)

        XCTAssertEqual(sut.containerView.layer.borderWidth, 0.0)
        let expectedColor = UIColor.clear.cgColor
        XCTAssertEqual(sut.containerView.layer.borderColor, expectedColor)
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
