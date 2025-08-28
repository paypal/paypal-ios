/// Enum class to specify the type of funding for an order.
/// For more information go to: https://developer.paypal.com/docs/checkout/pay-later/us/
public enum PayPalWebCheckoutFundingSource: String {

    /// PayPal Credit will launch the web checkout flow and display PayPal Credit funding to eligible customers
    /// Eligible costumers receive a revolving line of credit that they can use to pay over time.
    case paypalCredit = "credit"

    // NEXT_MAJOR_VERSION: rename to `payLater`
    /// PayLater will launch the web checkout flow and display Pay Later offers to eligible customers,
    /// which include short-term, interest-free payments and other special financing options
    case paylater = "paylater"

    /// PayPal will launch the web checkout for a one-time PayPal Checkout flow
    case paypal = "paypal"
}
