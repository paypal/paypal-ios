import UIKit

final class GetBillingAgreementTokenWithoutPurchase {

    func execute(accessToken: String) async throws -> String {
        let baToken = try await DemoMerchantAPI.sharedService.createBillingAgreementToken(
            accessToken: accessToken,
            billingAgremeentTokenRequest: GetBillingAgreementTokenWithoutPurchase.request
        )
        return baToken.tokenID
    }

    private static let request = BillingAgreementWithoutPurchaseRequest(
        descrption: "Billing Agreement",
        shippingAddress: ShippingAddress(
            line1: "1350 North First Street",
            city: "San Jose",
            state: "CA",
            postalCode: "95112",
            countryCode: "US",
            recipientName: "John Doe"
        ),
        payer: Payer(
            paymentMethod: "PAYPAL"
        ),
        plan: Plan(
            type: "MERCHANT_INITIATED_BILLING",
            merchantPreferences: MerchantPreferences(
                returnUrl: "https://example.com/return",
                cancelUrl: "https://example.com/cancel",
                notifyUrl: "https://example.com/notify",
                acceptedPymtType: "INSTANT",
                skipShippingAddress: false,
                immutableShippingAddress: true
            )
        )
    )
}
