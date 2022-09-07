import UIKit

final class GetApprovalSessionID {

    func execute(accessToken: String) async throws -> String? {
        let vaultSessionID = try await DemoMerchantAPI.sharedService.createApprovalSessionID(
            accessToken: accessToken,
            approvalSessionRequest: request
        )

        let approvalSessionIDLink = vaultSessionID.links.first { $0.rel == "approve" }
        if let hrefLink = approvalSessionIDLink?.href {
            return URLComponents(string: hrefLink)?.queryItems?.first { $0.name == "approval_session_id" }?.value
        }
        return nil
    }

    private let request = ApprovalSessionRequest(
        customerId: "abcd1234",
        source: Source(
            paypal: PayPalSource(
                usageType: "MERCHANT",
                customerType: "CONSUMER"
            )
        ),
        applicationContext: ApplicationContext(
            returnUrl: "https://example.com",
            cancelUrl: "https://example.com",
            locale: "en-US",
            paymentMethodPreference: PaymentMethodPreference(
                payePreferred: "IMMEDIATE_PAYMENT_REQUIRED",
                payerSelected: "PAYPAL"
            )
        )
    )
}
