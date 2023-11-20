import Foundation
import CorePayments
import PayPalWebPayments

class PayPalWebViewModel: ObservableObject, PayPalWebCheckoutDelegate {

    @Published var state: CurrentState = .idle
    @Published var intent: Intent = .authorize
    @Published var order: Order?
    @Published var checkoutResult: PayPalWebCheckoutResult?

    var payPalWebCheckoutClient: PayPalWebCheckoutClient?

    let configManager = CoreConfigManager(domain: "PayPalWeb Payments")

    func createOrder(amount: String, intent: String) async throws {
        let amountRequest = Amount(currencyCode: "USD", value: amount)
        // TODO: might need to pass in payee as payee object or as auth header
        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: intent,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
        )

        do {
            DispatchQueue.main.async {
                self.state = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams, selectedMerchantIntegration: DemoSettings.merchantIntegration
            )
            DispatchQueue.main.async {
                self.state = .loaded
                self.order = order
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(message: error.localizedDescription)
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }

    func paymentButtonTapped(funding: PayPalWebCheckoutFundingSource) {
        if let orderID = order?.id {
            checkoutWithPayPal(orderID: orderID, funding: funding)
        }
    }

    func checkoutWithPayPal(orderID: String, funding: PayPalWebCheckoutFundingSource) {
        Task {
            do {
                payPalWebCheckoutClient = try await getPayPalClient()
                payPalWebCheckoutClient?.delegate = self
                guard let client = payPalWebCheckoutClient else {
                    print("Error in initializing paypal webcheckout client")
                    return
                }
                let payPalRequest = PayPalWebCheckoutRequest(orderID: orderID, fundingSource: funding)
                client.start(request: payPalRequest)
            } catch {
                print("Error in starting paypal webcheckout client")
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

    func paypalWebCheckoutFailureResult(checkoutError: CorePayments.CoreSDKError) {
        DispatchQueue.main.async {
            self.state = .error(message: checkoutError.localizedDescription)
        }
    }

    func completeOrder() async throws {
        if let orderID = order?.id {
            switch intent {
            case .capture:
                try await captureOrder(orderID: orderID)
            case .authorize:
                try await authorizeOrder(orderID: orderID)
            }
        }
    }

    func captureOrder(orderID: String) async throws {
        do {
            DispatchQueue.main.async {
                self.state = .loading
            }
            try await DemoMerchantAPI.sharedService.captureOrder(
                orderID: orderID,
                selectedMerchantIntegration: DemoSettings.merchantIntegration
            )
            DispatchQueue.main.async {
                self.state = .loaded
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func authorizeOrder(orderID: String) async throws {
        do {
            DispatchQueue.main.async {
                self.state = .loading
            }
            try await DemoMerchantAPI.sharedService.authorizeOrder(
                orderID: orderID,
                selectedMerchantIntegration: DemoSettings.merchantIntegration
            )
            DispatchQueue.main.async {
                self.state = .loaded
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(message: error.localizedDescription)
            }
            print("Error authorizing order: \(error.localizedDescription)")
        }
    }

    // MARK: - PayPalWeb Checkout Delegate

    func payPal(
        _ payPalClient: PayPalWebCheckoutClient,
        didFinishWithResult result: PayPalWebCheckoutResult
    ) {
        checkoutResult = result
    }

    func payPal(_ payPalClient: PayPalWebPayments.PayPalWebCheckoutClient, didFinishWithError error: CorePayments.CoreSDKError) {
        paypalWebCheckoutFailureResult(checkoutError: error)
    }

    func payPalDidCancel(_ payPalClient: PayPalWebPayments.PayPalWebCheckoutClient) {
        print("PayPal Checkout Canceled")
    }
}
