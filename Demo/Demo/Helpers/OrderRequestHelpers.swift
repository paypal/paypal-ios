import Foundation
import Card
import PayPalCheckout

enum OrderRequestHelpers {

    static var shippingMethods = getShippingMethods()

    static func getOrderParams(shippingChangeEnabled: Bool) -> CreateOrderParams {
        return CreateOrderParams(
            intent: "AUTHORIZE",
            purchaseUnits: [
                PurchaseUnit(
                    amount: Amount(
                        currencyCode: "USD",
                        value: "100.0"
                    ),
                    items: [
                        Item(
                            description: "Running, Size 10.5",
                            name: "T-Shirt",
                            quantity: "2",
                            unitAmount: Amount(
                                currencyCode: "USD",
                                value: "00.00"
                            )
                        ),
                        Item(
                            description: "Green XL",
                            name: "Shoes",
                            quantity: "1",
                            unitAmount: Amount(
                                currencyCode: "USD",
                                value: "00.00"
                            )
                        )
                    ],
                    referenceId: "PUHF",
                    shipping: Shipping(
                        shippingName: ShippingName(fullName: "Cookie Monster"),
                        address: Address(
                            addressLine1: "123 Townsend St",
                            addressLine2: "Floor 6",
                            locality: "San Francisco",
                            region: "CA",
                            postalCode: "94107",
                            countryCode: "US"
                        ),
                        options: shippingChangeEnabled ? shippingMethods : nil
                    )
                )
            ],
            applicationContext: ApplicationContext(
                returnUrl: "https://example.com/return",
                cancelUrl: "https://example.com/cancel",
                shippingPreference: shippingChangeEnabled ? "GET_FROM_FILE" : "SET_PROVIDED_ADDRESS",
                userAction: "PAY_NOW"
            )
        )
    }

    private static func getShippingMethods() -> [ShippingMethod]? {
        let currency = "USD"
        let ship1 = ShippingMethod(
            id: "ShipTest1",
            label: "standard shipping",
            selected: true,
            type: "SHIPPING",
            amount: Amount(currencyCode: currency, value: "3.99")
        )
        let ship2 = ShippingMethod(
            id: "ShipTest2",
            label: "cheap shipping",
            selected: false,
            type: "SHIPPING",
            amount: Amount(currencyCode: currency, value: "0.99")
        )
        let ship3 = ShippingMethod(
            id: "ShipTest3",
            label: "express shipping",
            selected: false,
            type: "SHIPPING",
            amount: Amount(currencyCode: currency, value: "7.99")
        )
        let pick1 = ShippingMethod(
            id: "PickTest1",
            label: "please pick it up from store",
            selected: false,
            type: "PICKUP",
            amount: Amount(currencyCode: currency, value: "0")
        )
        let pick2 = ShippingMethod(
            id: "PickTest2",
            label: "pick it up from warehouse",
            selected: false,
            type: "PICKUP",
            amount: Amount(currencyCode: currency, value: "0")
        )
        let pick3 = ShippingMethod(
            id: "PickTest3",
            label: "pick it from HQ",
            selected: false,
            type: "PICKUP",
            amount: Amount(currencyCode: currency, value: "0")
        )
        return [ship1, ship2, ship3, pick1, pick2, pick3]
    }
}
