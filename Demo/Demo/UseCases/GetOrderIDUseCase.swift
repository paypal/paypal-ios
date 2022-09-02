import UIKit

final class GetOrderIDUseCase {

    func execute() async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(order: GetOrderIDUseCase.orderWithFixedShipping)
        return order.id
    }

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
