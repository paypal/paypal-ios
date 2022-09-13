import Foundation
import Card
import PayPalCheckout

enum OrderRequestHelpers {

    static let requestWithFixedShipping = CreateOrderParams(
        intent: "AUTHORIZE",
        purchaseUnits: [
            PurchaseUnit(
                amount: Amount(
                    currencyCode: "USD",
                    value: "100.0",
                    breakdown: Breakdown(
                        discount: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        handling: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        itemTotal: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        shipping: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        shippingDiscount: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        taxTotal: AmountBreakdown(
                            currencyCode: "USD",
                            value: "00.00"
                        )
                    )
                ),
                customId: "CUST-HighFashions",
                description: "Sporting Goods",
                items: [
                    Item(
                        category: "PHYSICAL_GOODS",
                        description: "Running, Size 10.5",
                        name: "T-Shirt",
                        quantity: "2",
                        sku: "sku2",
                        tax: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        unitAmount: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        )
                    ),
                    Item(
                        category: "PHYSICAL_GOODS",
                        description: "Green XL",
                        name: "Shoes",
                        quantity: "1",
                        sku: "sku01",
                        tax: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        ),
                        unitAmount: Amount(
                            currencyCode: "USD",
                            value: "00.00"
                        )
                    )
                ],
                payee: Payee(
                    emailAddress: "merchant@email.com",
                    merchantId: "X5XAHHCG636FA"
                ),
                referenceId: "PUHF",
                shipping: Shipping(
                    address: Address(
                        addressLine1: "123 Townsend St",
                        addressLine2: "Floor 6",
                        locality: "San Francisco",
                        region: "CA",
                        postalCode: "94107",
                        countryCode: "US"
                    )
                ),
                softDescriptor: "HighFashions"
            )
        ],
        applicationContext: ApplicationContext(
            returnUrl: "https://example.com/return",
            cancelUrl: "https://example.com/cancel",
            locale: "de-DE",
            shippingPreference: "SET_PROVIDED_ADDRESS",
            userAction: "PAY_NOW",
            landingPage: "BILLING"
        )
    )
}
