import UIKit
import PayPalCheckout

final class GetOrderRequestUseCase {

    func execute() -> OrderRequest {
        createOrderRequest()
    }

    private func createOrderRequest(
        amountValue: String = "0.01",
        shippingPreference: OrderApplicationContext.ShippingPreference = .getFromFile,
        userAction: OrderApplicationContext.UserAction = .continue,
        currency: CurrencyCode = .usd,
        orderIntent: OrderIntent = .capture,
        processingInstruction: ProcessingInstruction? = nil
    ) -> OrderRequest {
        let address = OrderAddress(
            countryCode: "US",
            addressLine1: "345 Sesame Street",
            addressLine2: "Apt 9",
            adminArea1: "NY",
            adminArea2: "New York City",
            postalCode: "32422"
        )
        let context = OrderApplicationContext(
            brandName: "Example Inc",
            locale: "de-DE",
            shippingPreference: shippingPreference,
            userAction: userAction,
            paymentMethod: nil,
            returnUrl: "https://example.com/return",
            cancelUrl: "https://example.com/cancel",
            storedPaymentSource: nil
        )
        return OrderRequest(
            intent: orderIntent,
            purchaseUnits: [
                PayPalCheckout.PurchaseUnit(
                    amount: PayPalCheckout.PurchaseUnit.Amount(currencyCode: currency, value: amountValue),
                    shipping: PayPalCheckout.PurchaseUnit.Shipping(
                        shippingName: PayPalCheckout.PurchaseUnit.ShippingName(fullName: "Cookie Monster"),
                        address: address,
                        options: buildShippingMethods(
                            currency: currency,
                            pref: shippingPreference
                        )
                    )
                )
            ],
            processingInstruction: processingInstruction ?? .none,
            payer: nil,
            applicationContext: context
        )
    }

    private func buildShippingMethods(
        currency: CurrencyCode,
        pref: OrderApplicationContext.ShippingPreference
    ) -> [ShippingMethod]? {
        guard pref == .getFromFile  else {
            return nil
        }
        let ship1 = ShippingMethod(
            id: "ShipTest1",
            label: "standard shipping",
            selected: true,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: "3.99")
        )
        let ship2 = ShippingMethod(
            id: "ShipTest2",
            label: "cheap shipping",
            selected: false,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: "0.99")
        )
        let ship3 = ShippingMethod(
            id: "ShipTest3",
            label: "express shipping",
            selected: false,
            type: .shipping,
            amount: UnitAmount(currencyCode: currency, value: "7.99")
        )
        let pick1 = ShippingMethod(
            id: "PickTest1",
            label: "please pick it up from store",
            selected: true,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )
        let pick2 = ShippingMethod(
            id: "PickTest2",
            label: "pick it up from warehouse",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )
        let pick3 = ShippingMethod(
            id: "PickTest3",
            label: "pick it from HQ",
            selected: false,
            type: .pickup,
            amount: UnitAmount(currencyCode: currency, value: "0")
        )
        return [ship2, ship3, ship1, pick1, pick2, pick3]
    }
}
