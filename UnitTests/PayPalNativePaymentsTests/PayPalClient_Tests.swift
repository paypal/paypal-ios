import XCTest
import PayPalCheckout
@testable import CorePayments
@testable import PayPalNativePayments
@testable import TestShared

class PayPalClient_Tests: XCTestCase {

    let config = CoreConfig(clientID: "testClientID", environment: .sandbox)
    lazy var mockNetworkingClient = MockNetworkingClient(coreConfig: config)

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
        networkingClient: mockNetworkingClient
    )

    func testUserAuthenticationIsPassed_returnsRequestEmail() async {
      let modifiedRequest = PayPalNativeCheckoutRequest(orderID: "fake-order-id", userAuthenticationEmail: "fake_user_email@mock.paypal.com")
      let mockPayPalDelegate = MockPayPalDelegate()
      payPalClient.delegate = mockPayPalDelegate
      await payPalClient.start(request: modifiedRequest)
      XCTAssertEqual(mockNativeCheckoutProvider.userAuthenticationEmail, "fake_user_email@mock.paypal.com")
    }

    func testUserAuthenticationIsNil_returnsNilForEmail() async {
      let modifiedRequest = PayPalNativeCheckoutRequest(orderID: "fake-order-id")
      let mockPayPalDelegate = MockPayPalDelegate()
      payPalClient.delegate = mockPayPalDelegate
      await payPalClient.start(request: request)
      XCTAssertNil(mockNativeCheckoutProvider.userAuthenticationEmail)
    }

    func testStart_whenNativeSDKOnApproveCalled_returnsPayPalResult() async {

        let mockOrderID = "mock_order_id"
        let mockPayerID = "mock_payer_id"
        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start(request: request)
        mockNativeCheckoutProvider.triggerApprove(orderdID: mockOrderID, payerID: mockPayerID)
        let result = mockPayPalDelegate.capturedResult
        XCTAssertEqual(result?.orderID, mockOrderID)
        XCTAssertEqual(result?.payerID, mockPayerID)
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

    func testStart_whenNativeSDKOnErrorCalled_returnsCheckoutError() async {

        let errorMessage = "error_message"
        let mockPayPalDelegate = MockPayPalDelegate()
        payPalClient.delegate = mockPayPalDelegate
        await payPalClient.start(request: request)
        mockNativeCheckoutProvider.triggerError(errorReason: errorMessage)
        XCTAssertEqual(mockPayPalDelegate.capturedError?.errorDescription, errorMessage)
    }
    
    func testStart_whenNativeSDKShippingAddressChange_returnsNewAddress() async {
        let mockShippingDelegate = MockPayPalNativeShipping()
        let mockShippingAddress = PayPalNativeShippingAddress(
            addressID: "id",
            adminArea1: "area1",
            adminArea2: "area2",
            postalCode: "postal_code",
            countryCode: "us"
        )
           
        payPalClient.shippingDelegate = mockShippingDelegate
        await payPalClient.start(request: request)
        mockNativeCheckoutProvider.triggerShippingChange(
            type: .shippingAddress,
            actions: PayPalNativePaysheetActions(MockShippingChangeActions()),
            address: mockShippingAddress
        )
        
        let capturedShippingAddress = mockShippingDelegate.capturedShippingAddress
        XCTAssertEqual(mockShippingAddress.addressID, capturedShippingAddress?.addressID)
        XCTAssertEqual(mockShippingAddress.adminArea1, capturedShippingAddress?.adminArea1)
        XCTAssertEqual(mockShippingAddress.adminArea2, capturedShippingAddress?.adminArea2)
        XCTAssertEqual(mockShippingAddress.postalCode, capturedShippingAddress?.postalCode)
        XCTAssertEqual(mockShippingAddress.countryCode, capturedShippingAddress?.countryCode)
    }
    
    func testStart_whenNativeSDKShippingMethodChange_returnsNewMethod() async {
        
        let mockShippingDelegate = MockPayPalNativeShipping()
        let mockShippingMethod = PayPalNativeShippingMethod(
            id: "id",
            label: "label",
            selected: true,
            type: .shipping,
            value: "0.0",
            currencyCode: "usd"
        )
        payPalClient.shippingDelegate = mockShippingDelegate
        await payPalClient.start(request: request)
        mockNativeCheckoutProvider.triggerShippingChange(
            type: .shippingMethod,
            actions: PayPalNativePaysheetActions(MockShippingChangeActions()),
            address: PayPalNativeShippingAddress(),
            method: mockShippingMethod
        )
        
        let capturedShippingMethod = mockShippingDelegate.capturedShippingMethod
        XCTAssertEqual(mockShippingMethod.id, capturedShippingMethod?.id)
        XCTAssertEqual(mockShippingMethod.label, capturedShippingMethod?.label)
        XCTAssertEqual(mockShippingMethod.currencyCode, capturedShippingMethod?.currencyCode)
        XCTAssertEqual(mockShippingMethod.value, capturedShippingMethod?.value)
        XCTAssertEqual(mockShippingMethod.type, capturedShippingMethod?.type)
        XCTAssertEqual(mockShippingMethod.selected, capturedShippingMethod?.selected)
    }
}
