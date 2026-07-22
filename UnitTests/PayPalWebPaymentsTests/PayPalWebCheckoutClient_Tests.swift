import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class PayPalClient_Tests: XCTestCase {
    
    var config: CoreConfig!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var payPalClient: PayPalWebCheckoutClient!
    var mockNetworkingClient: MockNetworkingClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockPatchCCOAPI: MockPatchCCOAPI!
    var mockCreateShopperSessionAPI: MockCreateShopperSessionAPI!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockPatchCCOAPI = MockPatchCCOAPI(coreConfig: config)
        mockCreateShopperSessionAPI = MockCreateShopperSessionAPI(coreConfig: config)

        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            clientConfigAPI: mockClientConfigAPI,
            patchCCOAPI: mockPatchCCOAPI,
            createShopperSessionAPI: mockCreateShopperSessionAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
    }

    func testStart_whenWebAuthenticationSessionCancelCalled_returnsCancellationError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.checkoutCanceledError.code)
                XCTAssertEqual(error.localizedDescription, PayPalError.checkoutCanceledError.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebSession_cancelled_returnsIsCheckoutCanceledTrue() {

        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertTrue(PayPalError.isCheckoutCanceled(error))
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalError.Code.webSessionError.rawValue,
            domain: PayPalError.domain,
            errorDescription: "Mock web session error description."
        )

        let expectation = self.expectation(description: "Call back invoked with error")

        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.webSessionError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenUpdateClientConfigFails_returnsErrorAndDoesNotStartWebSession() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubError = CoreSDKError(
            code: NetworkingError.Code.serverResponseError.rawValue,
            domain: NetworkingError.domain,
            errorDescription: "Target App not specified"
        )
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")

        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure when UpdateClientConfig fails")
            case .failure(let error):
                XCTAssertEqual(error.domain, NetworkingError.domain)
                XCTAssertEqual(error.code, NetworkingError.Code.serverResponseError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Target App not specified")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertNil(mockWebAuthenticationSession.lastLaunchedURL)
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")
        let expectation = self.expectation(description: "Call back invoked with error")
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: nil)

        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.malformedResultError.rawValue)
                XCTAssertEqual(error.localizedDescription, "Result did not contain the expected data.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testStart_whenWebResultIsCancelled_returnsCancellationError() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockWebAuthenticationSession.cannedResponseURL =
            URL(string: "sdk.ios.paypal://testurl.com/checkout?opType=cancel")
        
        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.checkoutCanceledError.rawValue)
                XCTAssertEqual(error.localizedDescription, "PayPal checkout has been canceled by the user")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")
        let expectation = self.expectation(description: "Call back invoked with error")
        payPalClient.start(request: request) { result in
            switch result {
            case .success(let result):
                XCTAssertEqual(result.orderID, "1234")
                XCTAssertEqual(result.payerID, "98765")
            case .failure:
                XCTFail("Expected success with PayPalCheckoutResult")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testpayPalCheckoutReturnURL_returnsCorrectURL() {
        let url = URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234")!
        let checkoutURL = payPalClient.payPalCheckoutReturnURL(payPalCheckoutURL: url)

        XCTAssertEqual(
            checkoutURL,
            URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234&redirect_uri=\(PayPalWebCheckoutClient.PayPalCheckoutCallbackURL.redirectURL)&native_xo=1")
        )
    }
}
