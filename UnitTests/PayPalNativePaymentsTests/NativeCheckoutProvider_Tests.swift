import UIKit
import PayPalCheckout
@testable import PayPalNativePayments
import XCTest

class NativeCheckoutProvider_Tests: XCTestCase {

    func testStart_whenStartIsCalled_checkoutIsInitialized() {
        let nativeCheckoutProvider = NativeCheckoutProvider(MockCheckout.self)
        nativeCheckoutProvider.start(
            presentingViewController: nil,
            orderID: "",
            onStartableApprove: { _, _ in },
            onStartableShippingChange: { _, _, _, _ in },
            onStartableCancel: { },
            onStartableError: { _ in },
            nxoConfig: CheckoutConfig(clientID: "")
        )
        
        XCTAssertTrue(MockCheckout.startInvoked)
        XCTAssertTrue(MockCheckout.isConfigSet)
        XCTAssertFalse(MockCheckout.showsExitAlert)
    }
}

class MockCheckout: CheckoutProtocol {
    
    static func start(
        presentingViewController: UIViewController?,
        createOrder: PayPalCheckout.CheckoutConfig.CreateOrderCallback?,
        onApprove: PayPalCheckout.CheckoutConfig.ApprovalCallback?,
        onShippingChange: PayPalCheckout.CheckoutConfig.ShippingChangeCallback?,
        onCancel: PayPalCheckout.CheckoutConfig.CancelCallback?,
        onError: PayPalCheckout.CheckoutConfig.ErrorCallback?
    ) {
        startInvoked = true
    }
    
    static var showsExitAlert = false
    
    static func set(config: PayPalCheckout.CheckoutConfig) {
        isConfigSet = true
    }
    
    static var startInvoked = false
    static var isConfigSet = false
}
