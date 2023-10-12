import Foundation

enum OrderRequestHelpers {

    static let orderAmount = 100.0
    static let currencyCode = "USD"
    
    static func getOrderRequest(_ shippingPreference: ShippingPreference) -> CreateOrderParams {
        return CreateOrderParams(
            applicationContext: ApplicationContext(userAction: "PAY_NOW", shippingPreference: shippingPreference.rawValue),
            // TODO: - All demo features should support both AUTHORIZE & CAPTURE testing
            intent: "AUTHORIZE",
            purchaseUnits: [
                PurchaseUnit(
                    shipping: Shipping(
                        address: Shipping.Address(
                            addressLine1: "345 Sesame Street",
                            addressLine2: "Apt 9",
                            adminArea2: "New York City",
                            adminArea1: "NY",
                            countryCode: "US",
                            postalCode: "32422"
                        ),
                        name: Shipping.Name(
                            fullName: "Cookie Monster"
                        ),
                        options: shippingPreference == .getFromFile ? getShippingMethods() : nil
                    ),
                    payee: Payee(merchantID: "X5XAHHCG636FA", emailAddress: "merchant@email.com"),
                    amount: Amount(currencyCode: "USD", value: String(orderAmount), breakdown: nil)
                )
            ]
        )
    }

    static func getAmount(shipping: Double = 3.99) -> Amount {
        Amount(
            currencyCode: currencyCode,
            value: String(orderAmount + shipping),
            breakdown: Amount.Breakdown(
                shipping: ItemTotal(
                    value: String(shipping),
                    currencyValue: String(shipping),
                    currencyCode: currencyCode
                ),
                itemTotal: ItemTotal(
                    value: String(orderAmount),
                    currencyValue: String(orderAmount),
                    currencyCode: currencyCode
                )
            )
        )
    }
    
    static func getShippingMethods(selectedID: String = "ShipTest1") -> [ShippingOption]? {
        let shipOption1 = ShippingOption(
            selected: false,
            id: "ShipTest1",
            amount: ItemTotal(
                value: "3.99",
                currencyValue: "3.99",
                currencyCode: currencyCode
            ),
            label: "Standard Shipping",
            type: "SHIPPING"
        )
        
        let shipOption2 = ShippingOption(
            selected: false,
            id: "ShipTest2",
            amount: ItemTotal(
                value: "0.99",
                currencyValue: "0.99",
                currencyCode: currencyCode
            ),
            label: "Cheap Shipping",
            type: "SHIPPING"
        )
        
        let shipOption3 = ShippingOption(
            selected: false,
            id: "ShipTest3",
            amount: ItemTotal(
                value: "7.99",
                currencyValue: "7.99",
                currencyCode: currencyCode
            ),
            label: "Express Shipping",
            type: "SHIPPING"
        )
        
        let shipOption4 = ShippingOption(
            selected: false,
            id: "PickTest1",
            amount: ItemTotal(
                value: "0",
                currencyValue: "0",
                currencyCode: currencyCode
            ),
            label: "Pick up from store",
            type: "PICKUP"
        )
        
        let shipOption5 = ShippingOption(
            selected: false,
            id: "PickTest2",
            amount: ItemTotal(
                value: "0",
                currencyValue: "0",
                currencyCode: currencyCode
            ),
            label: "Pick up from warehouse",
            type: "PICKUP"
        )
        
        var shippingOptions = [shipOption1, shipOption2, shipOption3, shipOption4, shipOption5]
        if let index = shippingOptions.firstIndex(where: { $0.id == selectedID }) {
            let shippingMethod = shippingOptions[index]
            shippingOptions[index] = ShippingOption(
                selected: true,
                id: selectedID,
                amount: shippingMethod.amount,
                label: shippingMethod.label,
                type: shippingMethod.type
            )
        }
        return shippingOptions
    }
}
