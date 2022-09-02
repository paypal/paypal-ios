import UIKit

final class GetBATokenWithoutPurchase {

    func execute(accessToken: String) async throws -> String {
        let baToken = try await DemoMerchantAPI.sharedService.createBAToken(
            accessToken: accessToken,
            baTokenRequest: GetBATokenWithoutPurchase.baTokenRequest
        )
        return baToken.tokenID
    }

    private static let baTokenRequest = """
        {
            "description": "Billing Agreement",
            "shipping_address": {
                "line1": "1350 North First Street",
                "city": "San Jose",
                "state": "CA",
                "postal_code": "95112",
                "country_code": "US",
                "recipient_name": "John Doe"
            },
            "payer": {
                "payment_method": "PAYPAL"
            },
            "plan": {
                "type": "MERCHANT_INITIATED_BILLING",
                "merchant_preferences": {
                    "return_url": "https://example.com/return",
                    "cancel_url": "https://example.com/cancel",
                    "notify_url": "https://example.com/notify",
                    "accepted_pymt_type": "INSTANT",
                    "skip_shipping_address": false,
                    "immutable_shipping_address": true
                }
            }
        }
    """
}
