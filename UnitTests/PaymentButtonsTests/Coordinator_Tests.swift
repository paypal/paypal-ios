import XCTest
@testable import PaymentButtons

class Coordinator_Tests: XCTestCase {

    var actionString: String = ""

    func testCoordinator_init() {
        let action = { self.actionTest() }
        let coordinator = Coordinator(action: action)

        coordinator.onAction(UIViewController())

        XCTAssertEqual(actionString, "Test action")
    }

    private func actionTest() {
        actionString = "Test action"
    }
}
