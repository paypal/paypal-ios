import PaymentsCore
import PayPalCheckout

// TODO: add documentation
extension CoreConfig {
    // TODO: handle this throw
    func toPayPalCheckoutConfig() throws -> CheckoutConfig {
        guard let returnUrl = returnUrl else {
            throw PayPalError.noReturnUrl
        }
        return CheckoutConfig(clientID: clientID, returnUrl: returnUrl, environment: environment.toPayPalCheckoutEnvironment())
    }
}
