import XCTest
import AuthenticationServices
@testable import PaymentsCore
@testable import PayPal

class PayPalClient_Tests: XCTestCase {

    let config = CoreConfig(clientID: "testClientID", environment: .sandbox)
    let context = MockViewController()

    lazy var paypalClient = PayPalClient(config: config)

    func testStart_whenInvalidBaseURLIsPassed_returnsPayPalURLError() {
//        config.environment.payPalBaseURL = ""
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {

    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {

    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalRequest(orderID: "1234")
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")

        paypalClient.start(
            request: request,
            context: context,
            webAuthenticationSession: mockWebAuthenticationSession
        ) { result in
            switch result {
            case .success(let result):
                XCTAssertEqual(result.orderID, "1234")
                XCTAssertEqual(result.payerID, "98765")
            case.failure:
                XCTFail()
            }
        }
    }
}
