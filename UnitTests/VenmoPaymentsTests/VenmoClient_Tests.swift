import XCTest
@testable import CorePayments
@testable import VenmoPayments
@testable import TestShared

// swiftlint:disable:next type_body_length
class VenmoClient_Tests: XCTestCase {

    var config: CoreConfig!
    var venmoClient: VenmoClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockFundingEligibilityAPI: MockGetFundingEligibilityAPI!
    var mockURLOpener: MockURLOpener!
    var mockNetworkingClient: MockNetworkingClient!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockFundingEligibilityAPI = MockGetFundingEligibilityAPI(coreConfig: config)
        mockURLOpener = MockURLOpener()
        mockWebAuthenticationSession = MockWebAuthenticationSession()

        venmoClient = VenmoClient(
            config: config,
            clientConfigAPI: mockClientConfigAPI,
            fundingEligibilityAPI: mockFundingEligibilityAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        venmoClient.application = mockURLOpener
    }

    // MARK: - Eligibility Tests

    func testStart_whenVenmoNotEligible_returnsEligibilityError() {
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: false, reasons: ["NOT_ENABLED"])
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        let expectation = expectation(description: "start(request:) completed")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        venmoClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure when Venmo is not eligible")
            case .failure(let error):
                XCTAssertEqual(error.domain, VenmoError.domain)
                XCTAssertEqual(error.code, VenmoError.Code.fundingEligibilityError.rawValue)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testStart_whenEligibilityCheckFails_returnsError() {
        mockFundingEligibilityAPI.stubError = CoreSDKError(
            code: 0,
            domain: "TestDomain",
            errorDescription: "Network error"
        )

        let expectation = expectation(description: "start(request:) completed")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        venmoClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure when eligibility check fails")
            case .failure(let error):
                XCTAssertEqual(error.errorDescription, "Network error")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - Web Flow URL Construction Tests

    func testStart_webFlow_whenEligible_launchesWebSessionWithSandboxURL() async throws {
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        // swiftlint:disable:next force_unwrapping
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=ORDER-123&PayerID=PAYER-456&approved=true"
        )!

        // appSwitchIfEligible defaults to false -> web flow
        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        let result = try await venmoClient.start(request: request)

        guard let launchedURL = mockWebAuthenticationSession.lastLaunchedURL else {
            XCTFail("Expected web authentication session to launch")
            return
        }

        let urlString = launchedURL.absoluteString
        XCTAssertTrue(urlString.contains("www.sandbox.paypal.com/smart/checkout/venmo"))
        XCTAssertTrue(urlString.contains("token=ORDER-123"))
        XCTAssertTrue(urlString.contains("fundingSource=venmo"))
        XCTAssertTrue(urlString.contains("env=sandbox"))
        XCTAssertTrue(urlString.contains("enableFunding=venmo"))
        XCTAssertNil(mockURLOpener.lastOpenedURL)
        XCTAssertEqual(result.orderID, "ORDER-123")
        XCTAssertEqual(result.payerID, "PAYER-456")
    }

    func testStart_webFlow_whenLive_usesCorrectBaseURL() async throws {
        let liveConfig = CoreConfig(clientID: "testClientID", environment: .live)
        let liveFundingEligibilityAPI = MockGetFundingEligibilityAPI(coreConfig: liveConfig)
        let liveNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: liveConfig))
        let liveClientConfigAPI = MockClientConfigAPI(coreConfig: liveConfig, networkingClient: liveNetworkingClient)
        let liveWebAuthenticationSession = MockWebAuthenticationSession()
        let liveClient = VenmoClient(
            config: liveConfig,
            clientConfigAPI: liveClientConfigAPI,
            fundingEligibilityAPI: liveFundingEligibilityAPI,
            webAuthenticationSession: liveWebAuthenticationSession
        )
        liveClient.application = mockURLOpener

        liveFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        liveClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        // swiftlint:disable:next force_unwrapping
        liveWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=ORDER-456&PayerID=PAYER-456&approved=true"
        )!

        let request = VenmoCheckoutRequest(orderID: "ORDER-456")
        _ = try await liveClient.start(request: request)

        guard let launchedURL = liveWebAuthenticationSession.lastLaunchedURL else {
            XCTFail("Expected web authentication session to launch")
            return
        }

        let urlString = launchedURL.absoluteString
        XCTAssertTrue(urlString.contains("www.paypal.com/smart/checkout/venmo"))
        XCTAssertTrue(urlString.contains("env=production"))
    }

    // MARK: - App Switch Open Tests

    func testStart_appSwitch_whenOpenURLFails_fallsBackToWebFlow() async throws {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = false
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        // swiftlint:disable:next force_unwrapping
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=ORDER-123&PayerID=PAYER-456&approved=true"
        )!

        let request = VenmoCheckoutRequest(orderID: "ORDER-123", appSwitchIfEligible: true)
        let result = try await venmoClient.start(request: request)

        XCTAssertNotNil(mockURLOpener.lastOpenedURL)
        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertEqual(result.orderID, "ORDER-123")
        XCTAssertEqual(result.payerID, "PAYER-456")
    }

    // MARK: - handleReturnURL Tests

    func testHandleReturnURL_success_returnsResult() {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout completed with result")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123", appSwitchIfEligible: true)
        venmoClient.start(request: request) { result in
            switch result {
            case .success(let checkoutResult):
                XCTAssertEqual(checkoutResult.orderID, "ORDER-123")
                XCTAssertEqual(checkoutResult.payerID, "PAYER-456")
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        // Wait for the app switch to be set up, then simulate return
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // swiftlint:disable:next force_unwrapping
            let returnURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=ORDER-123&PayerID=PAYER-456")!
            self.venmoClient.handleReturnURL(returnURL)
        }

        waitForExpectations(timeout: 5)
    }

    func testHandleReturnURL_cancel_returnsCanceledError() {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout canceled")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123", appSwitchIfEligible: true)
        venmoClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected cancellation error")
            case .failure(let error):
                XCTAssertTrue(VenmoError.isCheckoutCanceled(error))
            }
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // swiftlint:disable:next force_unwrapping
            let cancelURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout/cancel")!
            self.venmoClient.handleReturnURL(cancelURL)
        }

        waitForExpectations(timeout: 5)
    }

    func testHandleReturnURL_malformed_returnsMalformedError() {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout returned malformed")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123", appSwitchIfEligible: true)
        venmoClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected malformed error")
            case .failure(let error):
                XCTAssertEqual(error.domain, VenmoError.domain)
                XCTAssertEqual(error.code, VenmoError.Code.malformedResultError.rawValue)
            }
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // swiftlint:disable:next force_unwrapping
            let badURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?foo=bar")!
            self.venmoClient.handleReturnURL(badURL)
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - VenmoError Helper Tests

    func testIsCheckoutCanceled_withCanceledError_returnsTrue() {
        XCTAssertTrue(VenmoError.isCheckoutCanceled(VenmoError.checkoutCanceledError))
    }

    func testIsCheckoutCanceled_withOtherError_returnsFalse() {
        XCTAssertFalse(VenmoError.isCheckoutCanceled(VenmoError.venmoURLError))
    }

    func testIsCheckoutCanceled_withNonCoreSDKError_returnsFalse() {
        let nsError = NSError(domain: "test", code: 0)
        XCTAssertFalse(VenmoError.isCheckoutCanceled(nsError))
    }

    // MARK: - buildCheckoutURL Tests (Direct API URL contract)

    func testBuildCheckoutURL_sandbox_hasCorrectHost() throws {
        let sandboxConfig = CoreConfig(clientID: "testClientID", environment: .sandbox)
        let client = VenmoClient(
            config: sandboxConfig,
            clientConfigAPI: mockClientConfigAPI,
            fundingEligibilityAPI: mockFundingEligibilityAPI
        )

        let url = try client.buildCheckoutURL(request: VenmoCheckoutRequest(orderID: "ORDER-123"))
        XCTAssertEqual(url.host, "account.venmo.com")
    }

    func testBuildCheckoutURL_live_hasCorrectHost() throws {
        let liveConfig = CoreConfig(clientID: "testClientID", environment: .live)
        let liveNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: liveConfig))
        let liveClientConfigAPI = MockClientConfigAPI(coreConfig: liveConfig, networkingClient: liveNetworkingClient)
        let liveFundingEligibilityAPI = MockGetFundingEligibilityAPI(coreConfig: liveConfig)
        let client = VenmoClient(
            config: liveConfig,
            clientConfigAPI: liveClientConfigAPI,
            fundingEligibilityAPI: liveFundingEligibilityAPI
        )

        let url = try client.buildCheckoutURL(request: VenmoCheckoutRequest(orderID: "ORDER-123"))
        XCTAssertEqual(url.host, "account.venmo.com")
    }

    func testBuildCheckoutURL_custom_usesQAAppSwitchHost() throws {
        let customConfig = CoreConfig(
            clientID: "testClientID",
            environment: .custom(baseURL: "https://custom.example.com", graphQLURL: "https://custom.example.com/graphql")
        )
        let customNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: customConfig))
        let customClientConfigAPI = MockClientConfigAPI(coreConfig: customConfig, networkingClient: customNetworkingClient)
        let customFundingEligibilityAPI = MockGetFundingEligibilityAPI(coreConfig: customConfig)
        let client = VenmoClient(
            config: customConfig,
            clientConfigAPI: customClientConfigAPI,
            fundingEligibilityAPI: customFundingEligibilityAPI
        )

        let url = try client.buildCheckoutURL(request: VenmoCheckoutRequest(orderID: "ORDER-123"))
        XCTAssertEqual(url.host, "account.qa.venmo.com")
    }

    func testBuildCheckoutURL_hasCorrectPath() throws {
        let url = try venmoClient.buildCheckoutURL(request: VenmoCheckoutRequest(orderID: "ORDER-123"))
        XCTAssertEqual(url.path, "/go/web/paypal")
    }

    func testBuildCheckoutURL_hasTokenParam() throws {
        let items = try queryItems(forOrderID: "ORDER-ABC")
        XCTAssertEqual(items["token"], "ORDER-ABC")
    }

    func testBuildCheckoutURL_hasChannelInApp() throws {
        let items = try queryItems(forOrderID: "ORDER-123")
        XCTAssertEqual(items["channel"], "in-app")
    }

    func testBuildCheckoutURL_hasEnvParam() throws {
        let items = try queryItems(forOrderID: "ORDER-123")
        XCTAssertEqual(items["env"], "sandbox")
    }

    func testBuildCheckoutURL_sendsChannelEnvAndToken() throws {
        let url = try venmoClient.buildCheckoutURL(request: VenmoCheckoutRequest(orderID: "ORDER-123"))
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.count, 3)
        XCTAssertEqual(Set((components?.queryItems ?? []).map { $0.name }), ["channel", "env", "token"])
    }

    // MARK: buildCheckoutURL helpers

    private func queryItems(forOrderID orderID: String) throws -> [String: String] {
        queryItems(from: try venmoClient.buildCheckoutURL(request: VenmoCheckoutRequest(orderID: orderID)))
    }

    private func queryItems(from url: URL) -> [String: String] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return Dictionary(
            (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") }
        ) { first, _ in first }
    }
}
