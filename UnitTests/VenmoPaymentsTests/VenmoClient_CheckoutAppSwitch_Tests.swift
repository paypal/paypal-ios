import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import VenmoPayments
@testable import TestShared

class VenmoClient_CheckoutAppSwitch_Tests: XCTestCase {

    var config: CoreConfig!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var venmoClient: VenmoClient!
    var mockNetworkingClient: MockNetworkingClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockFundingEligibilityAPI: MockGetFundingEligibilityAPI!
    var mockURLOpener: MockURLOpener!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockFundingEligibilityAPI = MockGetFundingEligibilityAPI(coreConfig: config)

        mockURLOpener = MockURLOpener()

        venmoClient = VenmoClient(
            config: config,
            clientConfigAPI: mockClientConfigAPI,
            fundingEligibilityAPI: mockFundingEligibilityAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        venmoClient.application = mockURLOpener
    }

    // MARK: - App Switch Toggle Tests

    func test_appSwitchIfEligible_isFalseByDefault() {
        let request = VenmoCheckoutRequest(orderID: "test-order-id")
        XCTAssertFalse(request.appSwitchIfEligible)
    }

    func test_appSwitchDisabled_venmoInstalled_invokesWebFlow() async throws {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        // swiftlint:disable:next force_unwrapping
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=test-order-id&PayerID=test-payer-id&approved=true"
        )!

        let request = VenmoCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: false)
        let result = try await venmoClient.start(request: request)

        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNil(mockURLOpener.lastOpenedURL)
        XCTAssertEqual(result.orderID, "test-order-id")
        XCTAssertEqual(result.payerID, "test-payer-id")
    }

    func test_appSwitchEnabled_venmoNotInstalled_invokesWebFlow() async throws {
        mockURLOpener.mockIsVenmoAppInstalled = false
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        // swiftlint:disable:next force_unwrapping
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=test-order-id&PayerID=test-payer-id&approved=true"
        )!

        let request = VenmoCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)
        let result = try await venmoClient.start(request: request)

        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNil(mockURLOpener.lastOpenedURL)
        XCTAssertEqual(result.orderID, "test-order-id")
        XCTAssertEqual(result.payerID, "test-payer-id")
    }

    func test_appSwitchEnabled_venmoInstalled_opensCheckoutURL() async throws {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        let urlOpenedExpectation = XCTestExpectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            urlOpenedExpectation.fulfill()
        }

        let completionExpectation = XCTestExpectation(description: "App switch flow completion")

        let request = VenmoCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)
        venmoClient.start(request: request) { _ in
            completionExpectation.fulfill()
        }

        await fulfillment(of: [urlOpenedExpectation], timeout: 5.0)

        XCTAssertNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNotNil(mockURLOpener.lastOpenedURL)

        // Verify the URL is the Venmo checkout URL
        let openedURL = mockURLOpener.lastOpenedURL!  // swiftlint:disable:this force_unwrapping
        XCTAssertTrue(openedURL.absoluteString.contains("account.venmo.com"))
        XCTAssertTrue(openedURL.absoluteString.contains("token=test-order-id"))

        // Simulate return from Venmo app
        // swiftlint:disable:next force_unwrapping
        let returnURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=test-order-id&PayerID=test-payer-id&approved=true")!
        venmoClient.handleReturnURL(returnURL)

        await fulfillment(of: [completionExpectation], timeout: 5.0)
    }

    func test_appSwitchEnabled_opensChannelEnvAndTokenURL() async throws {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        let urlOpenedExpectation = XCTestExpectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            urlOpenedExpectation.fulfill()
        }

        let request = VenmoCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)
        venmoClient.start(request: request) { _ in }

        await fulfillment(of: [urlOpenedExpectation], timeout: 5.0)

        let openedURL = try XCTUnwrap(mockURLOpener.lastOpenedURL)
        let components = URLComponents(url: openedURL, resolvingAgainstBaseURL: false)
        let items = Dictionary(
            (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") },
            uniquingKeysWith: { first, _ in first }
        )

        XCTAssertEqual(openedURL.host, "account.venmo.com")
        XCTAssertEqual(openedURL.path, "/go/web/paypal")
        XCTAssertEqual(items["channel"], "in-app")
        XCTAssertEqual(items["env"], "sandbox")
        XCTAssertEqual(items["token"], "test-order-id")
        XCTAssertEqual(components?.queryItems?.count, 3)
    }

    func test_appSwitchOpenFails_fallsBackToWebFlow() async throws {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = false
        mockFundingEligibilityAPI.stubEligibilityResponse = VenmoFundingEligibility(eligible: true, reasons: nil)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)

        // swiftlint:disable:next force_unwrapping
        mockWebAuthenticationSession.cannedResponseURL = URL(
            string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=test-order-id&PayerID=test-payer-id&approved=true"
        )!

        let request = VenmoCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)
        let result = try await venmoClient.start(request: request)

        XCTAssertNotNil(mockURLOpener.lastOpenedURL)
        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertEqual(result.orderID, "test-order-id")
        XCTAssertEqual(result.payerID, "test-payer-id")
    }
}
