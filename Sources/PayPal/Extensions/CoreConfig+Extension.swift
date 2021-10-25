#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

extension CoreConfig {

    /// Convert `PaymentsCore.CoreConfig` to `PayPalCheckout.CheckoutConfig`
    /// This function will throw an error if there is no `returnURL`
    func toPayPalCheckoutConfig() throws -> CheckoutConfig {
        guard let returnUrl = returnUrl else {
            throw PayPalError.noReturnUrl
        }
        return CheckoutConfig(clientID: clientID, returnUrl: returnUrl, environment: environment.toPayPalCheckoutEnvironment())
    }
}
