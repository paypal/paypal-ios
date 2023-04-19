@testable import PayPalNativePayments

class MockPayPalNativeShipping: PayPalNativeShippingDelegate {
    
    var capturedShippingAddress: PayPalNativeShippingAddress?
    var capturedShippingMethod: PayPalNativeShippingMethod?
    
    func paypal(
        _ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient,
        didShippingAddressChange shippingAddress: PayPalNativePayments.PayPalNativeShippingAddress,
        withAction shippingActions: PayPalNativePayments.PayPalNativeShippingActions
    ) {
        capturedShippingAddress = shippingAddress
    }
    
    func paypal(
        _ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient,
        didShippingMethodChange shippingMethod: PayPalNativePayments.PayPalNativeShippingMethod,
        withAction shippingActions: PayPalNativePayments.PayPalNativeShippingActions
    ) {
        capturedShippingMethod = shippingMethod
    }
}
