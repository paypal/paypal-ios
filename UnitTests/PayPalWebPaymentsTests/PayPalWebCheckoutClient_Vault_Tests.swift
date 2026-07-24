import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class PayPalClient_Vault_Tests: XCTestCase {

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

    func testVault_whenSuccessUrl_ReturnsVaultToken() {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let expectedTokenIDResult = "fakeTokenID"
        let expectedSessionIDResult = "fakeSessionID"

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success(let cardVaultResult):
                XCTAssertEqual(expectedTokenIDResult, cardVaultResult.tokenID)
                XCTAssertEqual(expectedSessionIDResult, cardVaultResult.approvalSessionID)
            case .failure:
                XCTFail("Expected success with CardVaultResult")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_whenCancelUrl_ReturnsVaultToken() {

        mockWebAuthenticationSession.cannedResponseURL =
            URL(string: "sdk.ios.paypal://testurl.com/checkout/cancel?approval_session_id=$approvalSessionId")

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.vaultCanceledError.rawValue)
                XCTAssertEqual(error.localizedDescription, "PayPal vault has been canceled by the user")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testVault_whenWebSession_cancelled() {

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, PayPalError.domain)
                XCTAssertEqual(error.code, PayPalError.Code.vaultCanceledError.rawValue)
                XCTAssertEqual(error.localizedDescription, "PayPal vault has been canceled by the user")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenWebSession_cancelled_returnsIsVaultCanceledTrue() {

        mockWebAuthenticationSession.cannedErrorResponse = ASWebAuthenticationSessionError(
            .canceledLogin,
            userInfo: ["Description": "Mock cancellation error description."]
        )

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with cancellation error")
            case .failure(let error):
                XCTAssertTrue(PayPalError.isVaultCanceled(error))
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenWebSession_returnsDefaultError() {

        let expectedError = CoreSDKError(
            code: PayPalError.Code.webSessionError.rawValue,
            domain: PayPalError.domain,
            errorDescription: PayPalError.payPalVaultResponseError.errorDescription
        )
        mockWebAuthenticationSession.cannedErrorResponse = expectedError

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenSuccessUrl_missingToken_returnsError() {

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://vault/success?approval_token_id=&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let expectedError = CoreSDKError(
            code: PayPalError.payPalVaultResponseError.code,
            domain: PayPalError.domain,
            errorDescription: PayPalError.payPalVaultResponseError.errorDescription
        )

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
            switch result {
            case .success:
                XCTFail("Expected failure with error")
            case .failure(let error):
                XCTAssertEqual(error.domain, expectedError.domain)
                XCTAssertEqual(error.code, expectedError.code)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testVault_whenUpdateClientConfigFails_returnsErrorAndDoesNotStartWebSession() {
        mockClientConfigAPI.stubError = CoreSDKError(
            code: NetworkingError.Code.serverResponseError.rawValue,
            domain: NetworkingError.domain,
            errorDescription: "Target App not specified"
        )
        mockWebAuthenticationSession.cannedResponseURL =
            URL(string: "sdk.ios.paypal://vault/success?approval_token_id=fakeTokenID&approval_session_id=fakeSessionID")

        let expectation = expectation(description: "vault(url:) completed")

        let vaultRequest = PayPalVaultRequest(setupTokenID: "fakeTokenID")
        payPalClient.vault(vaultRequest) { result in
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

        waitForExpectations(timeout: 10)
        XCTAssertNil(mockWebAuthenticationSession.lastLaunchedURL)
    }
}
