import Foundation
import PayPalCheckout

enum OrderRequestHelpers {

    static var orderAmount = 100.0


    static func getOrderRequest() -> OrderRequest {
        return OrderRequest(
            intent: .authorize,
            purchaseUnits: [
                PayPalCheckout.PurchaseUnit(
                    amount: PayPalCheckout.PurchaseUnit.Amount(
                        currencyCode: .usd,
                        value: String(orderAmount)
                    ),
                    shipping: PayPalCheckout.PurchaseUnit.Shipping(
                        shippingName: PayPalCheckout.PurchaseUnit.ShippingName(fullName: "Cookie Monster"),
                        address: OrderAddress(
                            countryCode: "US",
                            addressLine1: "345 Sesame Street",
                            addressLine2: "Apt 9",
                            adminArea1: "NY",
                            adminArea2: "New York City",
                            postalCode: "32422"
                        ),
                        options: getShippingMethods(baseValue: 0)
                    )
                )
            ],
            applicationContext: OrderApplicationContext(
                shippingPreference: .getFromFile,
                userAction: .payNow,
                returnUrl: "https://example.com/return",
                cancelUrl: "https://example.com/cancel"
            )
        )
    }

    static func getShippingMethods(baseValue: Int) -> [PayPalCheckout.ShippingMethod] {
        let currency = CurrencyCode.usd
        let ship1 = PayPalCheckout.ShippingMethod(
            id: "ShipTest1",
            label: "standard shipping",
            selected: true,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: String(3.99 + Double(baseValue)))
        )
        let ship2 = PayPalCheckout.ShippingMethod(
            id: "ShipTest2",
            label: "cheap shipping",
            selected: false,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: String(0.99 + Double(baseValue)))
        )
        let ship3 = PayPalCheckout.ShippingMethod(
            id: "ShipTest3",
            label: "express shipping",
            selected: false,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: String(7.99 + Double(baseValue)))
        )
        let pick1 = PayPalCheckout.ShippingMethod(
            id: "PickTest1",
            label: "please pick it up from store",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )
        let pick2 = PayPalCheckout.ShippingMethod(
            id: "PickTest2",
            label: "pick it up from warehouse",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )
        let pick3 = PayPalCheckout.ShippingMethod(
            id: "PickTest3",
            label: "pick it from HQ",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )
        return [ship1, ship2, ship3, pick1, pick2, pick3]
    }
}
