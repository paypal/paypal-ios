import XCTest
@testable import CorePayments
@testable import VenmoPayments
@testable import TestShared

class VenmoClient_Tests: XCTestCase {

    var config: CoreConfig!
    var venmoClient: VenmoClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockFundingEligibilityAPI: MockGetFundingEligibilityAPI!
    var mockURLOpener: MockURLOpener!
    var mockNetworkingClient: MockNetworkingClient!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockFundingEligibilityAPI = MockGetFundingEligibilityAPI(coreConfig: config)
        mockURLOpener = MockURLOpener()

        venmoClient = VenmoClient(
            config: config,
            clientConfigAPI: mockClientConfigAPI,
            fundingEligibilityAPI: mockFundingEligibilityAPI
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

    // MARK: - URL Construction Tests

    func testStart_whenEligible_opensURL() {
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            expectation.fulfill()
        }

        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        venmoClient.start(request: request) { _ in }

        waitForExpectations(timeout: 5)

        guard let openedURL = mockURLOpener.lastOpenedURL else {
            XCTFail("Expected URL to be opened")
            return
        }

        let urlString = openedURL.absoluteString
        XCTAssertTrue(urlString.contains("sandbox.paypal.com/smart/checkout/venmo"))
        XCTAssertTrue(urlString.contains("orderID=ORDER-123"))
        XCTAssertTrue(urlString.contains("fundingSource=venmo"))
        XCTAssertTrue(urlString.contains("env=sandbox"))
        XCTAssertTrue(urlString.contains("enableFunding=venmo"))
    }

    func testStart_whenLive_usesCorrectBaseURL() {
        let liveConfig = CoreConfig(clientID: "testClientID", environment: .live)
        let liveClient = VenmoClient(
            config: liveConfig,
            clientConfigAPI: mockClientConfigAPI,
            fundingEligibilityAPI: mockFundingEligibilityAPI
        )
        liveClient.application = mockURLOpener

        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            expectation.fulfill()
        }

        let request = VenmoCheckoutRequest(orderID: "ORDER-456")
        liveClient.start(request: request) { _ in }

        waitForExpectations(timeout: 5)

        guard let openedURL = mockURLOpener.lastOpenedURL else {
            XCTFail("Expected URL to be opened")
            return
        }

        let urlString = openedURL.absoluteString
        XCTAssertTrue(urlString.contains("www.paypal.com/smart/checkout/venmo"))
        XCTAssertTrue(urlString.contains("env=production"))
    }

    // MARK: - App Switch Open Tests

    func testStart_whenOpenURLFails_returnsError() {
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockURLOpener.mockOpenURLSuccess = false

        let expectation = expectation(description: "start(request:) completed")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        venmoClient.start(request: request) { result in
            switch result {
            case .success:
                XCTFail("Expected failure when URL cannot be opened")
            case .failure(let error):
                XCTAssertEqual(error.domain, VenmoError.domain)
                XCTAssertEqual(error.code, VenmoError.Code.venmoURLError.rawValue)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - handleReturnURL Tests

    func testHandleReturnURL_success_returnsResult() {
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout completed with result")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
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
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout canceled")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
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
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout returned malformed")

        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
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

        let url = try client.buildCheckoutURL(orderID: "ORDER-123")
        XCTAssertEqual(url.host, "account.qa.venmo.com")
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

        let url = try client.buildCheckoutURL(orderID: "ORDER-123")
        XCTAssertEqual(url.host, "account.venmo.com")
    }

    func testBuildCheckoutURL_hasCorrectPath() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "ORDER-123")
        XCTAssertEqual(url.path, "/go/web/paypal")
    }

    func testBuildCheckoutURL_hasTokenParam() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "ORDER-ABC")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let tokenItem = components?.queryItems?.first { $0.name == "token" }

        XCTAssertNotNil(tokenItem)
        XCTAssertEqual(tokenItem?.value, "ORDER-ABC")
    }

    func testBuildCheckoutURL_doesNotHaveOrderIDParam() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "ORDER-ABC")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let orderIDItem = components?.queryItems?.first { $0.name == "orderID" }

        XCTAssertNil(orderIDItem)
    }

    func testBuildCheckoutURL_hasReturnFlowAUTO() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "ORDER-123")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let returnFlowItem = components?.queryItems?.first { $0.name == "return_flow" }

        XCTAssertNotNil(returnFlowItem)
        XCTAssertEqual(returnFlowItem?.value, "AUTO")
    }

    func testBuildCheckoutURL_hasExactlyTwoQueryParams() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "ORDER-123")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        XCTAssertEqual(components?.queryItems?.count, 2)
    }

    func testBuildCheckoutURL_sandbox_fullURL() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "MY-ORDER")
        XCTAssertEqual(url.absoluteString, "https://account.qa.venmo.com/go/web/paypal?token=MY-ORDER&return_flow=AUTO")
    }

    func testBuildCheckoutURL_live_fullURL() throws {
        let liveConfig = CoreConfig(clientID: "testClientID", environment: .live)
        let liveNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: liveConfig))
        let liveClientConfigAPI = MockClientConfigAPI(coreConfig: liveConfig, networkingClient: liveNetworkingClient)
        let liveFundingEligibilityAPI = MockGetFundingEligibilityAPI(coreConfig: liveConfig)
        let client = VenmoClient(
            config: liveConfig,
            clientConfigAPI: liveClientConfigAPI,
            fundingEligibilityAPI: liveFundingEligibilityAPI
        )

        let url = try client.buildCheckoutURL(orderID: "MY-ORDER")
        XCTAssertEqual(url.absoluteString, "https://account.venmo.com/go/web/paypal?token=MY-ORDER&return_flow=AUTO")
    }
}
