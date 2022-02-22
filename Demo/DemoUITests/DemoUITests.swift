import XCTest

class DemoUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testExample() throws {
        _ = launchApp()
        XCTAssertTrue(true)
    }
}
