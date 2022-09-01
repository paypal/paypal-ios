import UIKit

final class GetBillingAgreementToken {

    func execute() async throws -> Order {
        return try await DemoMerchantAPI.sharedService.createOrder(order: GetBillingAgreementToken.baTokenRequest)
    }

    private static let baTokenRequest = """
        {
            "intent": "CAPTURE",
            "purchase_units": [
                {
                    "amount": {
                        "currency_code": "USD",
                        "value": "95.00"
                    }
                }
            ],
            "payment_source": {
                "paypal": {
                    "attributes": {
                        "vault": {
                            "confirm_payment_token": "ON_ORDER_COMPLETION",
                            "usage_type": "MERCHANT"
                        }
                    }
                }
            },
            "application_context": {
                "return_url": "https://example.com/returnUrl",
                "cancel_url": "https://example.com/cancelUrl",
                "shipping_preference": "NO_SHIPPING"
            }
        }
    """
}
