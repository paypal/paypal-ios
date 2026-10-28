import XCTest
@testable import CorePayments
@testable import VenmoPayments
@testable import TestShared

@MainActor
class VenmoClient_CheckoutAppSwitch_Tests: XCTestCase {

    var config: CoreConfig!
    var venmoClient: VenmoClient!
    var mockNetworkingClient: MockNetworkingClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockURLOpener: MockURLOpener!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox, merchantID: "testMerchantID")
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockClientConfigAPI.stubUpdateClientConfigResponse = ClientConfigResponse(updateClientConfig: true)
        mockURLOpener = MockURLOpener()

        venmoClient = VenmoClient(config: config, clientConfigAPI: mockClientConfigAPI)
        venmoClient.application = mockURLOpener
    }

    func testStart_opensCheckoutURL_whenVenmoInstalled() async throws {
        try await assertOpensCheckoutURL(venmoInstalled: true)
    }

    func testStart_opensCheckoutURL_whenVenmoNotInstalled() async throws {
        try await assertOpensCheckoutURL(venmoInstalled: false)
    }

    func testStart_opensChannelAndTokenURL() async throws {
        try await assertOpensCheckoutURL(venmoInstalled: false)

        let openedURL = try XCTUnwrap(mockURLOpener.lastOpenedURL)
        let components = URLComponents(url: openedURL, resolvingAgainstBaseURL: false)
        let items = Dictionary(
            (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") }
        ) { first, _ in first }

        XCTAssertEqual(openedURL.host, "account.ext.live.venmo.com")
        XCTAssertEqual(openedURL.path, "/go/web/paypal")
        XCTAssertEqual(items["channel"], "in-app")
        XCTAssertEqual(items["token"], "test-order-id")
        XCTAssertEqual(components?.queryItems?.count, 2)
    }

    func testStart_whenOpenFails_returnsFailure() async {
        mockURLOpener.mockOpenURLSuccess = false

        do {
            _ = try await venmoClient.start(orderID: "test-order-id")
            XCTFail("Expected failure")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.code, VenmoError.Code.venmoURLError.rawValue)
            XCTAssertNotNil(mockURLOpener.lastOpenedURL)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helpers

    private func assertOpensCheckoutURL(venmoInstalled: Bool) async throws {
        mockURLOpener.mockIsVenmoAppInstalled = venmoInstalled
        mockURLOpener.mockOpenURLSuccess = true

        let urlOpenedExpectation = XCTestExpectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            urlOpenedExpectation.fulfill()
        }
        let completionExpectation = XCTestExpectation(description: "Checkout completion")

        venmoClient.start(orderID: "test-order-id") { result in
            if case .success(let checkoutResult) = result {
                XCTAssertEqual(checkoutResult.orderID, "test-order-id")
                XCTAssertEqual(checkoutResult.payerID, "test-payer-id")
            } else {
                XCTFail("Expected success")
            }
            completionExpectation.fulfill()
        }

        await fulfillment(of: [urlOpenedExpectation], timeout: 5.0)

        let openedURL = try XCTUnwrap(mockURLOpener.lastOpenedURL)
        XCTAssertTrue(openedURL.absoluteString.contains("token=test-order-id"))

        // swiftlint:disable:next force_unwrapping
        let fakeReturnURL = URL(string: "https://example.com/success?token=test-order-id&PayerID=test-payer-id&approved=true")!
        venmoClient.handleReturnURL(fakeReturnURL)

        await fulfillment(of: [completionExpectation], timeout: 5.0)
    }
}
