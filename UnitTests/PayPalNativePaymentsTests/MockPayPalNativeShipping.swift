@testable import PayPalNativePayments

class MockPayPalNativeShipping: PayPalNativeShippingDelegate {
    
    var capturedShippingAddress: PayPalNativeShippingAddress?
    var capturedShippingMethod: PayPalNativeShippingMethod?
    
    func paypal(
        _ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient,
        shippingActions: PayPalNativePayments.PayPalNativeShippingActions,
        didShippingAddressChange shippingAddress: PayPalNativePayments.PayPalNativeShippingAddress
    ) {
        capturedShippingAddress = shippingAddress
    }
    
    func paypal(
        _ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient,
        shippingActions: PayPalNativePayments.PayPalNativeShippingActions,
        didShippingMethodChange shippingMethod: PayPalNativePayments.PayPalNativeShippingMethod
    ) {
        capturedShippingMethod = shippingMethod
    }
}
