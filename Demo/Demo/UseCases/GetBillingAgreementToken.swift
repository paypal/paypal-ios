import UIKit

final class GetBillingAgreementToken {

    func execute() async throws -> Order {
        return try await DemoMerchantAPI.sharedService.createOrder(orderParams: request)
    }

    private let request = CreateOrderParams(
        intent: "CAPTURE",
        purchaseUnits: [
            PurchaseUnit(
                amount: Amount(
                    currencyCode: "USD",
                    value: "95.00"
                )
            )
        ],
        paymentSource: PaymentSource(
            paypal: PayPalPaymentSource(
                attributes: Attributes(
                    vault: Vault(
                        confirmPaymentToken: "ON_ORDER_COMPLETION",
                        usageType: "MERCHANT"
                    )
                )
            )
        ),
        applicationContext: ApplicationContext(
            returnUrl: "https://example.com/returnUrl",
            cancelUrl: "https://example.com/cancelUrl",
            shippingPreference: "NO_SHIPPING"
        )
    )
}
