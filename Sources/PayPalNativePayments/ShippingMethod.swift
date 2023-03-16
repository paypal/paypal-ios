public struct ShippingMethod {
    
    public let selectedShippingMethod: ShippingUnit
    public let secondaryShippingMethods: [ShippingUnit]?
    
    public init(selectedShippingMethod: ShippingUnit, secondaryShippingMethods: [ShippingUnit]?) {
        self.selectedShippingMethod = selectedShippingMethod
        self.secondaryShippingMethods = secondaryShippingMethods
    }
}

public struct ShippingUnit {
    
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
    public internal(set) var selected: Bool

    /// The method by which the payer wants to get their items.
    public let type: ShippingType
    
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
    public let currencyCodeString: String?
    
    public init(id: String, label: String, selected: Bool, type: ShippingType, value: String?, currencyCodeString: String?) {
        self.id = id
        self.label = label
        self.selected = selected
        self.type = type
        self.value = value
        self.currencyCodeString = currencyCodeString
    }
}

public enum ShippingType: Int, CaseIterable, Codable {
        
    /// The payer intends to receive the items at a specified address.
    case shipping
    
    /// The payer intends to pick up the items at a specified address. For example, a store address.
    case pickup
}
