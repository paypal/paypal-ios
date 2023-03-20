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
    
    let request = PayPalNativeCheckoutRequest(orderID: "fake-order-id")

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
        await payPalClient.start(request: request)
        
        XCTAssertEqual(mockPayPalDelegate.capturedError?.code, 1)
        XCTAssertEqual(mockPayPalDelegate.capturedError?.domain, "CorePaymentsErrorDomain")
        XCTAssertEqual(mockPayPalDelegate.capturedError?.errorDescription, "Error fetching clientID. Contact developer.paypal.com/support.")
    }

    // todo: check for approval result instead of cancel
    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start(request: request)
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPayPalDelegate.paypalDidCancel)
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellation() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start(request: request)
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPayPalDelegate.paypalDidCancel)
    }

    func testStart_whenNativeSDKOnStart_callbackIsTriggered() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start(request: request)
        XCTAssert(mockPayPalDelegate.paypalDidStart)
    }

    // todo: check for error case instead of cancel
    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() async {

        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start(request: request)
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPayPalDelegate.paypalDidCancel)
    }
}
