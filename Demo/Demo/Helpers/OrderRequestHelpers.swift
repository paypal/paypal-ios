import Foundation

enum OrderRequestHelpers {

    static var orderAmount = 100.0
    static var currencyCode = "USD"
    
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

    static func getAmount(value: Double = orderAmount, shipping: Double = 3.99) -> Amount {
        Amount(
            currencyCode: currencyCode,
            value: String(value + shipping),
            breakdown: Amount.Breakdown(
                shipping: ItemTotal(
                    value: String(shipping),
                    currencyValue: String(shipping),
                    currencyCode: currencyCode
                ),
                itemTotal: ItemTotal(
                    value: String(value),
                    currencyValue: String(value),
                    currencyCode: currencyCode
                )
            )
        )
    }
    
    static func getShippingMethods(baseValue: Int = 0, selectedID: String = "ShipTest1") -> [ShippingOption]? {
        let shipOption1 = ShippingOption(
            selected: false,
            id: "ShipTest1",
            amount: ItemTotal(
                value: String(3.99 + Double(baseValue)),
                currencyValue: String(3.99 + Double(baseValue)),
                currencyCode: "USD"
            ),
            label: "Standard Shipping",
            type: "SHIPPING"
        )
        
        let shipOption2 = ShippingOption(
            selected: false,
            id: "ShipTest2",
            amount: ItemTotal(
                value: String(0.99 + Double(baseValue)),
                currencyValue: String(0.99 + Double(baseValue)),
                currencyCode: "USD"
            ),
            label: "Cheap Shipping",
            type: "SHIPPING"
        )
        
        let shipOption3 = ShippingOption(
            selected: false,
            id: "ShipTest3",
            amount: ItemTotal(
                value: String(7.99 + Double(baseValue)),
                currencyValue: String(7.99 + Double(baseValue)),
                currencyCode: "USD"
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
                currencyCode: "USD"
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
                currencyCode: "USD"
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

//    static func getShippingMethods(baseValue: Int = 0, selectedID: String = "ShipTest1") -> [PayPalCheckout.ShippingMethod] {
//        let currency = CurrencyCode.usd
//        let ship1 = PayPalCheckout.ShippingMethod(
//            id: "ShipTest1",
//            label: "standard shipping",
//            selected: false,
//            type: .shipping,
//            amount: UnitAmount(currencyCode: currency, value: String(3.99 + Double(baseValue)))
//        )
//        let ship2 = PayPalCheckout.ShippingMethod(
//            id: "ShipTest2",
//            label: "cheap shipping",
//            selected: false,
//            type: .shipping,
//            amount: UnitAmount(currencyCode: currency, value: String(0.99 + Double(baseValue)))
//        )
//        let ship3 = PayPalCheckout.ShippingMethod(
//            id: "ShipTest3",
//            label: "express shipping",
//            selected: false,
//            type: .shipping,
//            amount: UnitAmount(currencyCode: currency, value: String(7.99 + Double(baseValue)))
//        )
//        let pick1 = PayPalCheckout.ShippingMethod(
//            id: "PickTest1",
//            label: "please pick it up from store",
//            selected: false,
//            type: .pickup,
//            amount: UnitAmount(currencyCode: currency, value: "0")
//        )
//        let pick2 = PayPalCheckout.ShippingMethod(
//            id: "PickTest2",
//            label: "pick it up from warehouse",
//            selected: false,
//            type: .pickup,
//            amount: UnitAmount(currencyCode: currency, value: "0")
//        )
//        let pick3 = PayPalCheckout.ShippingMethod(
//            id: "PickTest3",
//            label: "pick it from HQ",
//            selected: false,
//            type: .pickup,
//            amount: UnitAmount(currencyCode: currency, value: "0")
//        )
//        var shippingOptions = [ship1, ship2, ship3, pick1, pick2, pick3]
//        if let index = shippingOptions.firstIndex(where: { $0.id == selectedID }) {
//            let shippingMethod = shippingOptions[index]
//            shippingOptions[index] = PayPalCheckout.ShippingMethod(
//                id: selectedID,
//                label: shippingMethod.label,
//                selected: true,
//                type: shippingMethod.type,
//                amount: shippingMethod.amount
//            )
//        }
//        return shippingOptions
//    }
}
