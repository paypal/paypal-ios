import XCTest

private let defaultWaitTime: TimeInterval = 20.0

extension XCUIElement {

    func waitForExistence() -> Bool {
        return waitForExistence(timeout: defaultWaitTime)
    }
}
