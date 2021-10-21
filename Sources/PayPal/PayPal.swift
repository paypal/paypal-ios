#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

public struct PayPal {
    public private(set) var text = "Hello, PayPal module!"

    public init() {
        let config = CheckoutConfig(clientID: <#T##String#>, returnUrl: <#T##String#>)
    }
}
