import XCTest
import AuthenticationServices
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

class PayPalClient_CheckoutAppSwitch_Toggle_tests: XCTestCase {
    
    var config: CoreConfig!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!
    var payPalClient: PayPalWebCheckoutClient!
    var mockNetworkingClient: MockNetworkingClient!
    var mockClientConfigAPI: MockClientConfigAPI!
    var mockPatchCCOAPI: MockPatchCCOAPI!
    var mockURLOpener: MockURLOpener!


    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockPatchCCOAPI = MockPatchCCOAPI(coreConfig: config)


        mockURLOpener = MockURLOpener()

        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            clientConfigAPI: mockClientConfigAPI,
            patchCCOAPI: mockPatchCCOAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
        payPalClient.application = mockURLOpener
    }

    func test_AppSwitchIfEligible_IsFalseByDefault() {
        let request = PayPalWebCheckoutRequest(orderID: "test-order-id")

        XCTAssertFalse(request.appSwitchIfEligible)
    }

    func test_AppSwitchIfEligible_False_App_Installed_True_Invokes_WebFlow() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true
        let request = PayPalWebCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: false)
        let expectedResult = PayPalWebCheckoutResult(orderID: "test-order-id", payerID: "test-payer-id")
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id")

        let result = try await payPalClient.start(request: request)

        XCTAssertNotNil(self.mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNil(self.mockURLOpener.lastOpenedURL)
        XCTAssertEqual( result.orderID, expectedResult.orderID)
        XCTAssertEqual(result.payerID, expectedResult.payerID)
    }

    func test_AppSwitchIfEligible_True_App_Installed_False_Invokes_WebFlow() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = false

        let request = PayPalWebCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)

        let expectedResult = PayPalWebCheckoutResult(orderID: "test-order-id", payerID: "test-payer-id")
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id")

        let result = try await payPalClient.start(request: request)
        XCTAssertNotNil(self.mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNil(self.mockURLOpener.lastOpenedURL)
        XCTAssertEqual(result.orderID, expectedResult.orderID)
        XCTAssertEqual(result.payerID, expectedResult.payerID)
    }

    func test_AppSwitchIfEligible_True_App_Installed_True_Ineligible_Invokes_WebFlow() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true

        let request = PayPalWebCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)

        let ineligibleResponse = AppSwitchEligibility(appSwitchEligible: false, redirectURL: nil, ineligibleReason: "test-ineligible")
        mockPatchCCOAPI.stubEligibilityResponse = ineligibleResponse

        let expectedResult = PayPalWebCheckoutResult(orderID: "test-order-id", payerID: "test-payer-id")
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id")

        let result = try await payPalClient.start(request: request)
        XCTAssertNotNil(mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNil(self.mockURLOpener.lastOpenedURL)
        XCTAssertEqual(result.orderID, expectedResult.orderID)
        XCTAssertEqual(result.payerID, expectedResult.payerID)
    }

    func test_AppSwitchIfEligible_True_App_Installed_True_Eligible_Invokes_AppFlow() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true

        let request = PayPalWebCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)

        let eligibleResponse = AppSwitchEligibility(
            appSwitchEligible: true,
            redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout?appSwitchEligible=true&token=test-order-id&tokenType=ORDER_ID",
            ineligibleReason: nil
        )
        mockPatchCCOAPI.stubEligibilityResponse = eligibleResponse
        mockURLOpener.mockOpenURLSuccess = true

        let expectation = XCTestExpectation(description: "App switch flow completion")

        let urlOpenedExpectation = XCTestExpectation(description: "URL opened")
        mockURLOpener.didOpenURLHandler = {
            urlOpenedExpectation.fulfill()
        }

        payPalClient.start(request: request) { _ in
            expectation.fulfill()
        }

        await fulfillment(of: [urlOpenedExpectation], timeout: 1.0)

        XCTAssertNil(self.mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertNotNil(self.mockURLOpener.lastOpenedURL)

        let returnURL = URL(string: "https://appSwitch.com/success?token=test-order-id&PayerID=test-payer-id")!
        payPalClient.handleReturnURL(returnURL)

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func test_AppSwitch_Failure_Invokes_WebFlow() async throws {
        mockURLOpener.mockIsPayPalAppInstalled = true

        let request = PayPalWebCheckoutRequest(orderID: "test-order-id", appSwitchIfEligible: true)

        let eligibleResponse = AppSwitchEligibility(
            appSwitchEligible: true,
            redirectURL: "https://www.sandbox.paypal.com/app-switch-checkout?appSwitchEligible=true&token=test-order-id&tokenType=ORDER_ID",
            ineligibleReason: nil
        )
        mockPatchCCOAPI.stubEligibilityResponse = eligibleResponse

        mockURLOpener.mockOpenURLSuccess = false

        let expectedResult = PayPalWebCheckoutResult(orderID: "test-order-id", payerID: "test-payer-id")
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.paypal://x-callback-url/paypal-sdk/paypal-checkout?token=test-order-id&PayerID=test-payer-id")

        let result = try await payPalClient.start(request: request)
        XCTAssertNotNil(self.mockURLOpener.lastOpenedURL)
        XCTAssertNotNil(self.mockWebAuthenticationSession.lastLaunchedURL)
        XCTAssertEqual(result.orderID, expectedResult.orderID)
        XCTAssertEqual(result.payerID, expectedResult.payerID)
    }
}
