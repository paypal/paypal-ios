import Foundation
import PayPalCheckout

enum OrderRequestHelpers {

    static var orderAmount = 100.0

    static func getOrderRequest(_ shippingPreference: OrderApplicationContext.ShippingPreference) -> OrderRequest {
        return OrderRequest(
            intent: .authorize,
            purchaseUnits: [
                PayPalCheckout.PurchaseUnit(
                    amount: getAmount(value: orderAmount),
                    payee: PayPalCheckout.PurchaseUnit.Payee(emailAddress: "merchant@email.com", merchantId: "X5XAHHCG636FA"),
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
                        options: shippingPreference == .getFromFile ? getShippingMethods() : nil
                    )
                )
            ],
            applicationContext: OrderApplicationContext(
                shippingPreference: shippingPreference,
                userAction: .payNow,
                returnUrl: "https://example.com/return",
                cancelUrl: "https://example.com/cancel"
            )
        )
    }
    
    static func getOrderRequest(_ shippingPreference: ShippingPreference) -> CreateOrderParams {
        return CreateOrderParams(
            applicationContext: ApplicationContext(
                userAction: "PAY_NOW",
                shippingPreference: "NO_SHIPPING"
            ),
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
                        )
                    ),
                    payee: Payee(merchantID: "X5XAHHCG636FA", emailAddress: "merchant@email.com"),
                    amount: Amount(currencyCode: "USD", value: "10.00")
                )
            ]
        )
    }

    static func getAmount(value: Double = orderAmount, shipping: Double = 3.99) -> PayPalCheckout.PurchaseUnit.Amount {
        return PayPalCheckout.PurchaseUnit.Amount(
            currencyCode: .usd,
            value: String(value + shipping),
            breakdown: PayPalCheckout.PurchaseUnit.Breakdown(
                itemTotal: UnitAmount(currencyCode: .usd, value: String(value)),
                shipping: UnitAmount(currencyCode: .usd, value: String(shipping))
            )
        )
    }

    static func getShippingMethods(baseValue: Int = 0, selectedID: String = "ShipTest1") -> [PayPalCheckout.ShippingMethod] {
        let currency = CurrencyCode.usd
        let ship1 = PayPalCheckout.ShippingMethod(
            id: "ShipTest1",
            label: "standard shipping",
            selected: false,
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
        var shippingOptions = [ship1, ship2, ship3, pick1, pick2, pick3]
        if let index = shippingOptions.firstIndex(where: { $0.id == selectedID }) {
            let shippingMethod = shippingOptions[index]
            shippingOptions[index] = PayPalCheckout.ShippingMethod(
                id: selectedID,
                label: shippingMethod.label,
                selected: true,
                type: shippingMethod.type,
                amount: shippingMethod.amount
            )
        }
        return shippingOptions
    }
}
