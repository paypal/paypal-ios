@testable import PayPalNativePayments

class MockPayPalNativeShipping: PayPalNativeShippingDelegate {
    
    var capturedShippingAddress: PayPalNativeShippingAddress?
    var capturedShippingMethod: PayPalNativeShippingMethod?
    
    func paypal(
        _ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient,
        didShippingAddressChange shippingAddress: PayPalNativePayments.PayPalNativeShippingAddress,
        withAction shippingActions: PayPalNativePayments.PayPalNativePaysheetActions
    ) {
        capturedShippingAddress = shippingAddress
    }
    
    func paypal(
        _ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient,
        didShippingMethodChange shippingMethod: PayPalNativePayments.PayPalNativeShippingMethod,
        withAction shippingActions: PayPalNativePayments.PayPalNativePaysheetActions
    ) {
        capturedShippingMethod = shippingMethod
    }
}
