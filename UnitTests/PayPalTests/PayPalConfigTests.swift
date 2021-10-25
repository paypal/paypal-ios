import XCTest
@testable import PaymentsCore
@testable import PayPal

final class PayPalConfig_Tests: XCTestCase {

    func testPayPalConfig_convertsToPayPalCheckoutConfigCorrectly() {
        let expectedClientID = "ClientID"
        let expectedEnvironment = Environment.sandbox
        let expectedReturnURL = "ReturnURL"
        let coreConfig = CoreConfig(
            clientID: expectedClientID,
            environment: expectedEnvironment,
            returnUrl: expectedReturnURL
        )

        do {
            let paypalCheckoutConfig = try coreConfig.toPayPalCheckoutConfig()

            XCTAssertEqual(paypalCheckoutConfig.clientID, expectedClientID)
            XCTAssertEqual(paypalCheckoutConfig.environment, expectedEnvironment.toPayPalCheckoutEnvironment())
            XCTAssertEqual(paypalCheckoutConfig.returnUrl, expectedReturnURL)
        }
        catch {
            XCTFail("Return URL was provided, we shouldn't be able to catch an error")
        }
    }

    func testPayPalConfig_returnURLNotProvided_throwsNoReturnUrlError() throws {
        let coreConfig = CoreConfig(clientID: "", environment: .sandbox)

        do {
            let _ = try coreConfig.toPayPalCheckoutConfig()
            XCTFail("Return URL wasn't provided, we should expect an error")
        }
        catch {
            let error = try XCTUnwrap(error as? PayPalSDKError)
            XCTAssertEqual(error.domain, PayPalError.domain)
            XCTAssertEqual(error.code, PayPalError.Code.noReturnUrl.rawValue)
        }
    }
}
