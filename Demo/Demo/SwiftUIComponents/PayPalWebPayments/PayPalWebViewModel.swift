import Foundation
import CorePayments
import PayPalWebPayments

class PayPalWebViewModel: ObservableObject, PayPalWebCheckoutDelegate {

    @Published var state: CurrentState = .idle
    @Published var intent: Intent = .authorize
    @Published var order: Order?
    @Published var checkoutResult: PayPalWebCheckoutResult?

    var payPalWebCheckoutClient: PayPalWebCheckoutClient?
    var orderID: String?

    let configManager = CoreConfigManager(domain: "PayPalWeb Payments")

    func createOrder(shouldVault: Bool) async throws {
        let amountRequest = Amount(currencyCode: "USD", value: "10.00")

        // TODO: might need to pass in payee as payee object or as auth header
        var vaultPayPalPaymentSource: VaultPayPalPaymentSource?
        if shouldVault {
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS", usageType: "MERCHANT", customerType: "CONSUMER"))
            // The returnURL is not used in our mobile SDK, but a required field for create order with PayPal payment source. DTPPCPSDK-1492 to track this issue
            let paypal = VaultPayPal(attributes: attributes, experienceContext: ExperienceContext(returnURL: "https://example.com/returnUrl", cancelURL: "https://example.com/cancelUrl"))
            vaultPayPalPaymentSource = VaultPayPalPaymentSource(paypal: paypal)
        }

        var vaultPaymentSource: VaultPaymentSource?
        if let vaultPayPalPaymentSource {
            vaultPaymentSource = .paypal(vaultPayPalPaymentSource)
        }

        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: intent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: vaultPaymentSource
        )

        do {
            updateState(.loading)
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams,
                selectedMerchantIntegration: DemoSettings.merchantIntegration
            )

            self.orderID = order.id

            // TODO: move back into update method

            DispatchQueue.main.async {
                self.order = order
            }
            updateState(.success)
            print("✅ fetched orderID: \(order.id) with status: \(order.status)")
        } catch {
            updateState(.error(message: error.localizedDescription))
            print("❌ failed to fetch orderID with error: \(error.localizedDescription)")
        }
    }

    func paymentButtonTapped(funding: PayPalWebCheckoutFundingSource) {
        Task {
            do {
                payPalWebCheckoutClient = try await getPayPalClient()
                payPalWebCheckoutClient?.delegate = self
                guard let payPalWebCheckoutClient else {
                    print("Error initializing PayPalWebCheckoutClient")
                    return
                }

                if let orderID {
                    let payPalRequest = PayPalWebCheckoutRequest(orderID: orderID, fundingSource: funding)
                    payPalWebCheckoutClient.start(request: payPalRequest)
                }
            } catch {
                print("Error starting PayPalWebCheckoutClient")
                state = .error(message: error.localizedDescription)
            }
        }
    }

    func getPayPalClient() async throws -> PayPalWebCheckoutClient {
        do {
            let config = try await configManager.getCoreConfig()
            let payPalClient = PayPalWebCheckoutClient(config: config)
            return payPalClient
        }
    }

    func completeTransaction() async throws {
        do {
            updateState(.loading)

            if let orderID {
                let order = try await DemoMerchantAPI.sharedService.completeOrder(intent: intent, orderID: orderID)
                // TODO: move back into update method
                DispatchQueue.main.async {
                    self.order = order
                }
                updateState(.success)
            }
        } catch {
            updateState(.error(message: error.localizedDescription))
            print("Error with \(intent) order: \(error.localizedDescription)")
        }
    }

    private func updateState(_ state: CurrentState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }

    // MARK: - PayPalWeb Checkout Delegate

    func payPal(
        _ payPalClient: PayPalWebCheckoutClient,
        didFinishWithResult result: PayPalWebCheckoutResult
    ) {
        updateState(.success)
        checkoutResult = result
    }

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        updateState(.error(message: error.localizedDescription))
    }

    func payPalDidCancel(_ payPalClient: PayPalWebCheckoutClient) {
        print("PayPal Checkout Canceled")
    }
}
