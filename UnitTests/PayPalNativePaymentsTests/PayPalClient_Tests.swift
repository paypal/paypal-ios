import XCTest
import PayPalCheckout
@testable import CorePayments
@testable import PayPalNativePayments
@testable import TestShared

class PayPalClient_Tests: XCTestCase {

    let config = CoreConfig(accessToken: "testAccessToken", environment: .sandbox)
    lazy var apiClient = MockAPIClient(coreConfig: config)

    let nxoConfig = CheckoutConfig(
        clientID: "testClientID",
        createOrder: nil,
        onApprove: nil,
        onShippingChange: nil,
        onCancel: nil,
        onError: nil,
        environment: .sandbox
    )

    lazy var mockNativeCheckoutProvider = MockNativeCheckoutProvider(nxoConfig: nxoConfig)
    lazy var payPalClient = PayPalNativeCheckoutClient(
        config: config,
        nativeCheckoutProvider: mockNativeCheckoutProvider,
        apiClient: apiClient
    )

    func testStart_ifClientIDFetchFails_returnsError() async {
        apiClient.cannedClientIDError = CoreSDKError(code: 0, domain: "", errorDescription: "")
        
        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start { _ in }
        
        XCTAssertEqual(mockPayPalDelegate.capturedError?.code, 1)
        XCTAssertEqual(mockPayPalDelegate.capturedError?.domain, "CorePaymentsErrorDomain")
        XCTAssertEqual(mockPayPalDelegate.capturedError?.errorDescription, "Error fetching clientID. Contact developer.paypal.com/support.")
    }

    // todo: check for approval result instead of cancel
    // JIRA ticket DTNOR-259
    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start { _ in }
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPayPalDelegate.paypalDidCancel)
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellation() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start { _ in }
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPayPalDelegate.paypalDidCancel)
    }

    func testStart_whenNativeSDKOnStart_callbackIsTriggered() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start { _ in }
        XCTAssert(mockPayPalDelegate.paypalDidStart)
    }

    // todo: check for error case instead of cancel
    // JIRA ticket DTNOR-259
    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start { _ in }
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPayPalDelegate.paypalDidCancel)
    }
    
    // MARK: - Analytics
    
    func testAnalyticsEvent_whenClientStarted_isSent() async {
        await payPalClient.start { _ in }
        XCTAssertEqual(apiClient.postedAnalyticsEvents.first, "paypal-native-checkout:started")
    }
    
    func testAnalyticsEvent_whenNXOCanceled_isSent() async {
        await payPalClient.start { _ in }
        
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssertEqual(apiClient.postedAnalyticsEvents[1], "paypal-native-checkout:canceled")
    }
    
    // TODO: - The following tests are blocked by inability to mock PayPalCheckout final classes.
    // JIRA ticket DTNOR-259
    
    func pendAnalyticsEvent_whenNXOError_isSent() async { }
    
    func pendAnalyticsEvent_whenNXOSucceeded_isSent() { }
    
    func pendAnalyticsEvent_whenNXOShippingAddressChanged_isSent() { }
}
