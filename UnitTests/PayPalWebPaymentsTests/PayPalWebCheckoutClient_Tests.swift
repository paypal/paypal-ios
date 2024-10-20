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

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        
        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            webAuthenticationSession: mockWebAuthenticationSession
        )
    }
    
    func testVault_whenSandbox_launchesCorrectURLInWebSession() async throws {
        let vaultRequest = PayPalVaultRequest(setupTokenID: "fake-token")

        do {
            _ = try? await payPalClient.vault(vaultRequest)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.mockWebAuthenticationSession.lastLaunchedURL?.absoluteString, "https://sandbox.paypal.com/agreements/approve?approval_session_id=fake-token")
        }
    }
    
    func testVault_whenLive_launchesCorrectURLInWebSession() async throws {
        config = CoreConfig(clientID: "testClientID", environment: .live)
        let payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        
        let vaultRequest = PayPalVaultRequest(setupTokenID: "fake-token")
        do {
            _ = try? await payPalClient.vault(vaultRequest)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.mockWebAuthenticationSession.lastLaunchedURL?.absoluteString, "https://paypal.com/agreements/approve?approval_session_id=fake-token")
        }
    }
    
    func testVault_whenSuccessUrl_ReturnsVaultToken() async throws {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID")

        let expectedTokenIDResult = "fakeTokenID"
        let expectedSessionIDResult = "fakeSessionID"

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        do {
            let result = try await payPalClient.vault(vaultRequest)
            XCTAssertEqual(expectedTokenIDResult, result.tokenID)
            XCTAssertEqual(expectedSessionIDResult, result.approvalSessionID)
        } catch {
            XCTFail("Returned Error. Should return PayPalVaultResult.")
        }
    }

    func testVault_whenWebSession_cancelled() async throws {

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")

        do {
            _ = try await payPalClient.vault(vaultRequest)
            XCTFail("Returned PayPalVaultResult. Should return Error.")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
            XCTAssertEqual(error.code, PayPalWebCheckoutClientError.Code.paypalCancellationError.rawValue)
            XCTAssertEqual(error.localizedDescription, "paypal checkout has been cancelled by the user.")
        }
    }

    func testVault_whenWebSession_returnsDefaultError() async throws {

        let expectedError = CoreSDKError(
            code: PayPalWebCheckoutClientError.Code.webSessionError.rawValue,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: PayPalWebCheckoutClientError.payPalVaultResponseError.errorDescription
        )
        mockWebAuthenticationSession.cannedErrorResponse = expectedError

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")

        do {
            _ = try await payPalClient.vault(vaultRequest)
            XCTFail("Returned PayPalVaultResult. Should return Error.")
        } catch let vaultError as CoreSDKError {
            XCTAssertEqual(vaultError.code, expectedError.code)
        }
    }

    func testVault_whenSuccessUrl_missingToken_returnsError() async throws {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=&approval_session_id=fakeSessionID")

        let expectedError = CoreSDKError(
            code: PayPalWebCheckoutClientError.payPalVaultResponseError.code,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: PayPalWebCheckoutClientError.payPalVaultResponseError.errorDescription
        )

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")

        do {
            _ = try await payPalClient.vault(vaultRequest)
            XCTFail("Returned PayPalVaultResult. Should return Error.")
        } catch let vaultError as CoreSDKError {
            XCTAssertEqual(vaultError.code, expectedError.code)
        }
    }

    func testStart_whenWebAuthenticationSessionCancelCalled_returnsCancellationError() async throws {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            _bridgedNSError: NSError(
                domain: ASWebAuthenticationSessionError.errorDomain,
                code: ASWebAuthenticationSessionError.canceledLogin.rawValue,
                userInfo: ["Description": "Mock cancellation error description."]
            )
        )

        do {
            _ = try await payPalClient.start(request: request)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
            XCTAssertEqual(error.code, PayPalWebCheckoutClientError.Code.paypalCancellationError.rawValue)
            XCTAssertEqual(error.localizedDescription, "paypal checkout has been cancelled by the user.")
        }
    }

    func testStart_whenWebAuthenticationSessions_returnsWebSessionError() async throws {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedErrorResponse = CoreSDKError(
            code: PayPalWebCheckoutClientError.Code.webSessionError.rawValue,
            domain: PayPalWebCheckoutClientError.domain,
            errorDescription: "Mock web session error description."
        )

        do {
            _ = try await payPalClient.start(request: request)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
            XCTAssertEqual(error.code, PayPalWebCheckoutClientError.Code.webSessionError.rawValue)
            XCTAssertEqual(error.localizedDescription, "Mock web session error description.")
        }
    }

    func testStart_whenResultURLMissingParameters_returnsMalformedResultError() async throws {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?PayerID=98765")

        do {
            _ = try await payPalClient.start(request: request)
            XCTFail("Invoked success() callback. Should invoke error().")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.domain, PayPalWebCheckoutClientError.domain)
            XCTAssertEqual(error.code, PayPalWebCheckoutClientError.Code.malformedResultError.rawValue)
            XCTAssertEqual(error.localizedDescription, "Result did not contain the expected data.")
        }
    }

    func testStart_whenWebResultIsSuccessful_returnsSuccessfulResult() async throws {
        let request = PayPalWebCheckoutRequest(orderID: "1234")

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://fakeURL?token=1234&PayerID=98765")

        do {
            let result = try await payPalClient.start(request: request)
            XCTAssertEqual(result.orderID, "1234")
            XCTAssertEqual(result.payerID, "98765")
        } catch {
            XCTFail("Returned error. Should return PayPalWebCheckoutResult.")
        }
    }

    func testpayPalCheckoutReturnURL_returnsCorrectURL() {
        let url = URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234")!
        let checkoutURL = payPalClient.payPalCheckoutReturnURL(payPalCheckoutURL: url)

        XCTAssertEqual(
            checkoutURL,
            URL(string: "https://sandbox.paypal.com/checkoutnow?token=1234&redirect_uri=sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout&native_xo=1")
        )
    }
}
