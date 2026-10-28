import XCTest
@testable import CorePayments
@testable import VenmoPayments
@testable import TestShared

@MainActor
class VenmoClient_Tests: XCTestCase {

    var config: CoreConfig!
    var venmoClient: VenmoClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockURLOpener: MockURLOpener!
    var mockNetworkingClient: MockNetworkingClient!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockURLOpener = MockURLOpener()

        venmoClient = VenmoClient(config: config, clientConfigAPI: mockClientConfigAPI)
        venmoClient.application = mockURLOpener
    }

    // MARK: - handleReturnURL Tests

    func testHandleReturnURL_success_returnsResult() {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout completed with result")

        venmoClient.start(orderID: "ORDER-123") { result in
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
            let returnURL = URL(
                string: "sdk.ios.paypal://x-callback-url/paypal-sdk/venmo-checkout?token=ORDER-123&PayerID=PAYER-456&approved=true"
            )!
            self.venmoClient.handleReturnURL(returnURL)
        }

        waitForExpectations(timeout: 5)
    }

    func testHandleReturnURL_canceledTrueQueryParam_returnsCancelError() {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout canceled via query param")

        venmoClient.start(orderID: "ORDER-123") { result in
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
            let url = URL(string: "https://example.com/return?token=ORDER-123&canceled=true")!
            self.venmoClient.handleReturnURL(url)
        }

        waitForExpectations(timeout: 5)
    }

    func testHandleReturnURL_malformed_returnsMalformedError() {
        mockURLOpener.mockIsVenmoAppInstalled = true
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout returned malformed")

        venmoClient.start(orderID: "ORDER-123") { result in
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

    func testHandleReturnURL_approvedWithoutPayerID_returnsMalformedError() {
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = expectation(description: "checkout returned malformed")

        venmoClient.start(orderID: "ORDER-123") { result in
            switch result {
            case .success:
                XCTFail("Expected malformed error")
            case .failure(let error):
                XCTAssertEqual(error.code, VenmoError.Code.malformedResultError.rawValue)
            }
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // swiftlint:disable:next force_unwrapping
            let url = URL(string: "https://example.com/success?token=ORDER-123&approved=true")!
            self.venmoClient.handleReturnURL(url)
        }

        waitForExpectations(timeout: 5)
    }

    func testHandleReturnURL_withoutStart_isIgnored() {
        // swiftlint:disable:next force_unwrapping
        venmoClient.handleReturnURL(URL(string: "https://example.com/success?approved=true&PayerID=P1")!)
        XCTAssertNil(venmoClient.appSwitchCompletion)
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
        let sandboxConfig = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        let client = VenmoClient(config: sandboxConfig, clientConfigAPI: mockClientConfigAPI)

        let url = try client.buildCheckoutURL(orderID: "ORDER-123")
        XCTAssertEqual(url.host, "account.ext.live.venmo.com")
    }

    func testBuildCheckoutURL_live_hasCorrectHost() throws {
        let liveConfig = CoreConfig(clientID: "testClientID", environment: .live, merchantID: "testMerchantID")
        let liveNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: liveConfig))
        let liveClientConfigAPI = MockClientConfigAPI(coreConfig: liveConfig, networkingClient: liveNetworkingClient)
        let client = VenmoClient(config: liveConfig, clientConfigAPI: liveClientConfigAPI)

        let url = try client.buildCheckoutURL(orderID: "ORDER-123")
        XCTAssertEqual(url.host, "account.venmo.com")
    }

    func testBuildCheckoutURL_custom_usesQAAppSwitchHost() throws {
        let customConfig = CoreConfig(
            clientID: "testClientID",
            environment: .custom(baseURL: "https://custom.example.com", graphQLURL: "https://custom.example.com/graphql"),
            merchantID: "testMerchantID"
        )
        let customNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: customConfig))
        let customClientConfigAPI = MockClientConfigAPI(coreConfig: customConfig, networkingClient: customNetworkingClient)
        let client = VenmoClient(config: customConfig, clientConfigAPI: customClientConfigAPI)

        let url = try client.buildCheckoutURL(orderID: "ORDER-123")
        XCTAssertEqual(url.host, "account.qa.venmo.com")
    }

    func testBuildCheckoutURL_hasCorrectPath() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "ORDER-123")
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

    func testBuildCheckoutURL_sendsOnlyChannelAndToken() throws {
        let url = try venmoClient.buildCheckoutURL(orderID: "ORDER-123")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(Set((components?.queryItems ?? []).map { $0.name }), ["channel", "token"])
    }

    // MARK: buildCheckoutURL helpers

    private func queryItems(forOrderID orderID: String) throws -> [String: String] {
        queryItems(from: try venmoClient.buildCheckoutURL(orderID: orderID))
    }

    private func queryItems(from url: URL) -> [String: String] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return Dictionary(
            (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") }
        ) { first, _ in first }
    }
}
