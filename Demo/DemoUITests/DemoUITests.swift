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
    }

    func testExample() throws {
        let app = launchApp()

        app.staticTexts["Create Order"].tap()

        // Ref: https://stackoverflow.com/a/47253096
        let startsWithPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Order ID:")
        _ = app.staticTexts.containing(startsWithPredicate).element.waitForExistence(timeout: 10.0)

        app.textFields["Card Number"].tap()
        typeNumbers(app: app, cardNumber: "4111111111111111")

        app.textFields["Expiration"].tap()
        typeNumbers(app: app, cardNumber: "0223")

        app.textFields["CVV"].tap()
        typeNumbers(app: app, cardNumber: "123")
        app.textFields["CVV"].typeText("\n")

        app.buttons["Capture Order"].tap()

        let approvedPredicate = NSPredicate(format: "label CONTAINS[c] %@", "processed orderID:")
        let elementExists = app.staticTexts.containing(approvedPredicate).element.waitForExistence(timeout: 20.0)

        XCTAssertTrue(elementExists)
    }
}
