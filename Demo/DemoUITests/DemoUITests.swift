import XCTest

class DemoUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    private func typeNumbers(app: XCUIApplication, cardNumber: String) {
        let keys = Array(cardNumber).map(String.init)
        for key in keys {
            app.keys[key].tap()
        }
        print(keys)
    }

    func testExample() throws {
        let app = launchApp()

        app.staticTexts["Create Order"].tap()
        _ = app.staticTexts["Order ID:"].waitForExistence(timeout: 10.0)

        app.textFields["Card Number"].tap()
        typeNumbers(app: app, cardNumber: "4111111111111111")

        app.textFields["Expiration"].tap()
        typeNumbers(app: app, cardNumber: "0220")

        app.textFields["CVV"].tap()
        typeNumbers(app: app, cardNumber: "123")

        app.buttons["Capture Order"].tap()

        XCTAssertTrue(true)
    }
}
