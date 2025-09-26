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


    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockNetworkingClient = MockNetworkingClient(http: MockHTTP(coreConfig: config))
        mockClientConfigAPI = MockClientConfigAPI(coreConfig: config, networkingClient: mockNetworkingClient)
        mockPatchCCOAPI = MockPatchCCOAPI(coreConfig: config)


        payPalClient = PayPalWebCheckoutClient(
            config: config,
            networkingClient: mockNetworkingClient,
            clientConfigAPI: mockClientConfigAPI,
            patchCCOAPI: mockPatchCCOAPI,
            webAuthenticationSession: mockWebAuthenticationSession
        )
    }

    func test_AppSwitchIfEligible_IsFalseByDefault() {
    }

    func test_AppSwitchIfEligible_False_App_Installed_True_Invokes_WebFlow() {
    }

    func test_AppSwitchIfEligible_True_App_Installed_False_Invokes_WebFlow() {
    }

    func test_AppSwitchIfEligible_True_App_Installed_True_Ineligible_Invokes_WebFlow() {
    }

    func test_AppSwitchIfEligible_True_App_Installed_True_Eligible_Invokes_AppFlow() {
    }
}
