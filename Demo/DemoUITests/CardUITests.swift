import XCTest

class CardUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testApproveOrder() throws {
        let app = launchApp(withArgs: ["-EnvironmentSandbox", "-DemoTypeCard", "-UIFrameworkUIKit"])

        app.button(named: "Create Order").tap()

        _ = app.staticText(containing: "Order ID:").waitForExistence()

        app.textField(named: "Card Number").tap()
        app.typeText("5288775404117508")

        app.textField(named: "Expiration").tap()
        app.typeText("0223")

        app.textField(named: "CVV").tap()
        app.typeText("123\n")

        app.button(named: "Capture Order").tap()

        let elementExists = app.staticText(containing: "status: CREATED").waitForExistence()
        XCTAssertTrue(elementExists)
    }
}
