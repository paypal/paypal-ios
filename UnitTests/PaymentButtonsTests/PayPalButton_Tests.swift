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
        XCTAssertEqual(sut.edges, PaymentButtonEdges.soft)
        XCTAssertEqual(sut.color, PaymentButtonColor.blue)
        XCTAssertNil(sut.label)
        XCTAssertNil(sut.insets)
    }

    func testInit_whenWhitePayPalButtonCreated_hasBorderConfiguration() {
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

    func testHighlightState_whenHighlightedTrue_setsCorrectPressedColor() {
        let sut = PayPalButton(color: .blue)
        sut.isHighlighted = true

        let expectedColor = PaymentButtonColor.blue.highlightedColor
        XCTAssertEqual(sut.containerView.backgroundColor, expectedColor)
    }

    func testHighlightState_whenHighlightedFalse_restoresDefaultColor() {
        let sut = PayPalButton(color: .blue)
        sut.isHighlighted = true
        sut.isHighlighted = false

        let expectedColor = PaymentButtonColor.blue.color
        XCTAssertEqual(sut.containerView.backgroundColor, expectedColor)
    }

    func testPressedState_whenWhite_setsE9E9E9() {
        let sut = PayPalButton(color: .white)
        sut.isHighlighted = true
        XCTAssertEqual(sut.containerView.backgroundColor, UIColor(hexString: "#E9E9E9"))
    }

    func testPressedState_whenBlack_sets696969() {
        let sut = PayPalButton(color: .black)
        sut.isHighlighted = true
        XCTAssertEqual(sut.containerView.backgroundColor, UIColor(hexString: "#696969"))
    }

    func testPressedState_whenBlue_sets696969() {
        let sut = PayPalButton(color: .blue)
        sut.isHighlighted = true
        XCTAssertEqual(sut.containerView.backgroundColor, UIColor(hexString: "#3DB5FF"))
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
