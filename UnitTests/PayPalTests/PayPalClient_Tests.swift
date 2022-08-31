import XCTest
import PayPalCheckout
@testable import PaymentsCore
@testable import PayPalNativeCheckout
@testable import TestShared

class PayPalClient_Tests: XCTestCase {

    private class MockPayPalDelegate: PayPalDelegate {

        func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: Approval) {
            capturedResult = approvalResult
        }

        func paypalDidShippingAddressChange(
            _ payPalClient: PayPalClient,
            shippingChange: ShippingChange,
            shippingChangeAction: ShippingChangeAction
        ) {
            self.shippingChange = shippingChange
        }

        var shippingChange: ShippingChange?
        var capturedResult: Approval?
        var capturedError: CoreSDKError?
        var paypalDidCancel = false

        func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
            capturedError = error
        }

        func paypalDidCancel(_ payPalClient: PayPalClient) {
            paypalDidCancel = true
        }
    }

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
    lazy var payPalClient = PayPalClient(config: config, nativeCheckoutProvider: mockNativeCheckoutProvider, apiClient: apiClient)

    // todo: check for approval result instead of cancel
    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() async {

        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate

        let orderID = "orderID"

        let mockPaypalDelegate = MockPayPalDelegate()
        await payPalClient.start(orderID: orderID, delegate: mockPaypalDelegate)
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPaypalDelegate.paypalDidCancel)
    }

    func testStart_whenNativeSDKOnCancelCalled_returnsCancellation() async {
        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate
        let orderID = "orderID"
        let mockPaypalDelegate = MockPayPalDelegate()
        await payPalClient.start(orderID: orderID, delegate: mockPaypalDelegate)
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPaypalDelegate.paypalDidCancel)
    }

    // todo: check for error case instead of cancel
    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() async {

        let delegate = MockPayPalDelegate()
        payPalClient.delegate = delegate
        let orderID = "orderID"
        let mockPaypalDelegate = MockPayPalDelegate()
        await payPalClient.start(orderID: orderID, delegate: mockPaypalDelegate)
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssert(mockPaypalDelegate.paypalDidCancel)
    }
}
