@testable import PayPalNativePayments

class MockPayPalNativeShipping: PayPalNativeShippingDelegate {
    func paypal(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient, shippingActions: PayPalNativePayments.PayPalNativeShippingActions, didShippingAddressChange shippingAddress: PayPalNativePayments.PayPalNativeShippingAddress) {
        
    }
    
    func paypal(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient, shippingActions: PayPalNativePayments.PayPalNativeShippingActions, didShippingMethodChange shippingMethod: PayPalNativePayments.PayPalNativeShippingMethod) {
        
    }
    

}
