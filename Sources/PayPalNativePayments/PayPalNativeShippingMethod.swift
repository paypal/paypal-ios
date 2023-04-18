import PayPalCheckout

// Wrapper for PayPalCheckout.ShippingMethod
/// The user's selected shipping method via the PayPal Native Checkout UI.
///
/// If you want to show shipping options in the PayPal Native Paysheet,
/// provide `purchase_units[].shipping.options` when creating an orderID with
/// the [`orders/v2` API](https://developer.paypal.com/docs/api/orders/v2/#definition-purchase_unit) on your server. Otherwise, our Paysheet won't display any shipping options.
public struct PayPalNativeShippingMethod {
    
    /// The method by which the payer wants to get their items.
    public enum DeliveryType: Int, CaseIterable, Codable {
            
        /// The payer intends to receive the items at a specified address.
        case shipping
        
        /// The payer intends to pick up the items at a specified address. For example, a store address.
        case pickup
        
        /// No delivery type specified.
        case none
    }
    
    /// A unique ID that identifies a payer-selected shipping option.
    public let id: String

    /// A description that the payer sees, which helps them choose an appropriate shipping option.
    /// For example, Free Shipping, USPS Priority Shipping, Expédition prioritaire USPS, or USPS yōuxiān fā huò.
    /// Localize this description to the payer's locale.
    public let label: String

    /// If true it represents the shipping option that the merchant expects to be selected for the buyer
    /// when they view the shipping options within the PayPal Checkout experience.
    /// The selected shipping option must match the shipping cost in the order breakdown.
    /// Only one shipping option per purchase unit can be selected.
    public let selected: Bool

    /// The method by which the payer wants to get their items.
    public let type: DeliveryType
    
    /// The shipping cost for the selected option, which might be:
    /// An integer for currencies like JPY that are not typically fractional.
    /// A decimal fraction for currencies like TND that are subdivided into thousandths.
    ///
    /// - Maximum length: 32.
    /// - Pattern: ^((-?[0-9]+)|(-?([0-9]+)?[.][0-9]+))$
    public let value: String?

    /// The [three-character ISO-4217 currency code](https://developer.paypal.com/docs/api/reference/currency-codes/)
    /// that identifies the currency.
    ///
    /// Currency code in text format (example: "USD")
    public let currencyCode: String?
    
    init(_ shippingMethod: PayPalCheckout.ShippingMethod) {
        self.id = shippingMethod.id
        self.label = shippingMethod.label
        self.selected = shippingMethod.selected
        self.type = shippingMethod.type.toMerchantFacingShippingType()
        self.value = shippingMethod.amount?.value
        self.currencyCode = shippingMethod.amount?.currencyCodeString
    }
    
    // For testing
    init(
        id: String,
        label: String,
        selected: Bool,
        type: DeliveryType,
        value: String,
        currencyCode: String
    ) {
        self.id = id
        self.label = label
        self.selected = selected
        self.type = type
        self.value = value
        self.currencyCode = currencyCode
    }
}

extension PayPalCheckout.ShippingType {
    
    func toMerchantFacingShippingType() -> PayPalNativeShippingMethod.DeliveryType {
        switch self {
        case .shipping:
            return PayPalNativeShippingMethod.DeliveryType.shipping
        case .pickup:
            return PayPalNativeShippingMethod.DeliveryType.pickup
        case .none:
            return PayPalNativeShippingMethod.DeliveryType.none
        @unknown default:
            return PayPalNativeShippingMethod.DeliveryType.none
        }
    }
}
