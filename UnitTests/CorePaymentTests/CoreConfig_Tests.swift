import XCTest
@testable import CorePayments

class CoreConfig_Tests: XCTestCase {

    func testInit_setsAllFields() {
        let config = CoreConfig(clientID: "test-client-id", environment: .sandbox, merchantID: "test-merchant-id")

        XCTAssertEqual(config.clientID, "test-client-id")
        XCTAssertEqual(config.environment, .sandbox)
        XCTAssertEqual(config.merchantID, "test-merchant-id")
    }

    func testInit_bnCodeDefaultsToNil() {
        let config = CoreConfig(clientID: "test-client-id", environment: .sandbox, merchantID: "test-merchant-id")

        XCTAssertNil(config.bnCode)
    }

    func testInit_withBnCode_setsBnCode() {
        let config = CoreConfig(
            clientID: "test-client-id",
            environment: .sandbox,
            merchantID: "test-merchant-id",
            bnCode: "test-bn-code"
        )

        XCTAssertEqual(config.bnCode, "test-bn-code")
    }
}
