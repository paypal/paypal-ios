import Foundation
import XCTest
@testable import CorePayments
@testable import PayPalWebPayments
@testable import TestShared

final class CreateShopperSessionAPI_Tests: XCTestCase {

    private var sut: CreateShopperSessionAPI!
    private var mockNetworkingClient: MockNetworkingClient!
    private var mockAuthSTS: MockAuthenticationSecureTokenServiceAPI!
    private let coreConfig = CoreConfig(
        clientID: "fake-client-id",
        merchantID: "fake-merchant-id",
        environment: .sandbox,
        bnCode: "test-bn"
    )

    override func setUp() {
        super.setUp()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: coreConfig))
        mockAuthSTS = MockAuthenticationSecureTokenServiceAPI(coreConfig: coreConfig)
        sut = CreateShopperSessionAPI(
            coreConfig: coreConfig,
            networkingClient: mockNetworkingClient,
            authenticationSecureTokenServiceAPI: mockAuthSTS
        )
    }

    func test_createShopperSessionForCheckout_sendsGraphQLWithLSAT() async throws {
        mockAuthSTS.stubbedAccessToken = "lsat_test"
        let successJSON = """
        {
          "data": {
            "createShopperSessionWithAppSwitchEligibility": {
              "sessionId": "ssid_123",
              "expiresAt": "2026-06-11T02:00:00Z",
              "checkoutUrls": {
                "appCheckout": "https://sandbox.paypal.com/app-checkout",
                "webCheckoutWeb": "https://sandbox.paypal.com/web-checkout",
                "appApprovalUrl": "https://sandbox.paypal.com/app-approval",
                "webApprovalUrl": "https://sandbox.paypal.com/web-approval"
              },
              "paymentMethodConfig": {
                "ssidRouting": true,
                "appSwitchEligible": true
              }
            }
          }
        }
        """
        mockNetworkingClient.stubHTTPResponse = HTTPResponse(status: 200, body: successJSON.data(using: .utf8))

        let request = PayPalWebCheckoutRequest(urlConfig: .testDefault, userAction: .payNow)
        let session = try await sut.createShopperSessionForCheckout(
            request: request,
            paypalAppInstalled: true,
            venmoAppInstalled: false
        )

        XCTAssertEqual(session.sessionId, "ssid_123")
        XCTAssertEqual(session.paymentMethodConfig?.ssidRouting, true)
        XCTAssertEqual(mockNetworkingClient.capturedAdditionalHeaders?[.authorization], "Bearer lsat_test")
        XCTAssertEqual(
            mockNetworkingClient.capturedGraphQLRequest?.query,
            ShopperSessionGraphQLQueries.createShopperSessionWithAppSwitchEligibility
        )
    }

    func test_createShopperSessionForVault_mapsSetupNowUserAction() async throws {
        mockAuthSTS.stubbedAccessToken = "lsat_test"
        let successJSON = """
        {
          "data": {
            "createShopperSessionWithAppSwitchEligibility": {
              "sessionId": "ssid_vault",
              "paymentMethodConfig": { "ssidRouting": true, "appSwitchEligible": true }
            }
          }
        }
        """
        mockNetworkingClient.stubHTTPResponse = HTTPResponse(status: 200, body: successJSON.data(using: .utf8))

        let request = PayPalVaultRequest(urlConfig: .testDefault, userAction: .setupNow)
        let session = try await sut.createShopperSessionForVault(
            request: request,
            paypalAppInstalled: false,
            venmoAppInstalled: true
        )

        XCTAssertEqual(session.sessionId, "ssid_vault")

        let vars = try XCTUnwrap(
            mockNetworkingClient.capturedGraphQLRequest?.variables as? CreateShopperSessionGraphQLVariables
        )
        XCTAssertEqual(vars.input.userAction, "setup_now")
        XCTAssertEqual(vars.input.flowType, PayPalCoreConstants.flowTypeBillingWithoutPurchase)
        XCTAssertEqual(vars.input.paypalAppInstalled, false)
        XCTAssertEqual(vars.input.venmoAppInstalled, true)
    }
}
