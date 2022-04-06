/// Enum class to specify the type of funding for an order
public enum PayPalWebCheckoutFundingSource: String {
    /// credit will launch the web checkout flow with credit funding selected
    case credit
    /// paylater will launch the web checkout flow with pay later selected
    case paylater
    /// paypal will launch the web checkout default flow
    case paypal
}
