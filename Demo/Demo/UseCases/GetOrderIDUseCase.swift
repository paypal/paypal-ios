import UIKit
import Card

final class GetOrderIDUseCase {

    func execute() async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(orderParams: requestWithFixedShipping)
        return order.id
    }

    private let requestWithFixedShipping = CreateOrderParams(
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

    private static let orderWithFixedShipping = """
        {
            "application_context": {
                "brand_name": "EXAMPLE INC",
                "cancel_url": "https://example.com/cancel",
                "landing_page": "BILLING",
                "locale": "de-DE",
                "return_url": "https://example.com/return",
                "shipping_preference": "SET_PROVIDED_ADDRESS",
                "user_action": "PAY_NOW"
            },
            "intent": "AUTHORIZE",
            "purchase_units": [{
                "amount": {
                    "breakdown": {
                        "discount": {
                            "currency_code": "USD",
                            "value": "00.00"
                        },
                        "handling": {
                            "currency_code": "USD",
                            "value": "00.00"
                        },
                        "item_total": {
                            "currency_code": "USD",
                            "value": "00.00"
                        },
                        "shipping": {
                            "currency_code": "USD",
                            "value": "0.00"
                        },
                        "shipping_discount": {
                            "currency_code": "USD",
                            "value": "00.00"
                        },
                        "tax_total": {
                            "currency_code": "USD",
                            "value": "100"
                        }
                    },
                    "currency_code": "USD",
                    "value": "100.00"
                },
                "custom_id": "CUST-HighFashions",
                "description": "Sporting Goods",
                "items": [{
                    "category": "PHYSICAL_GOODS",
                        "description": "Green XL",
                        "name": "T-Shirt",
                        "quantity": "1",
                        "sku": "sku01",
                        "tax": {
                            "currency_code": "USD",
                            "value": "00.00"
                        },
                        "unit_amount": {
                            "currency_code": "USD",
                            "value": "00.00"
                        }
                    },{
                        "category": "PHYSICAL_GOODS",
                        "description": "Running, Size 10.5",
                        "name": "Shoes",
                        "quantity": "2",
                        "sku": "sku02",
                        "tax": {
                            "currency_code": "USD",
                            "value": "00.00"
                        },
                        "unit_amount": {
                            "currency_code": "USD",
                            "value": "00.00"
                        }
                    }
                ],
                "payee": {
                    "email_address": "merchant@email.com",
                    "merchant_id": "X5XAHHCG636FA"
                },
                "reference_id": "PUHF",
                "shipping": {
                    "address": {
                        "address_line_1": "123 Townsend St",
                        "address_line_2": "Floor 6",
                        "admin_area_1": "CA",
                        "admin_area_2": "San Francisco",
                        "country_code": "US",
                        "postal_code": "94107"
                    }
                },
                "soft_descriptor": "HighFashions"
            }
        ]
    }
"""
}
