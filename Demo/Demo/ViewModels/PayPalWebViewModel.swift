import Foundation
import CorePayments
import PayPalWebPayments

class PayPalWebViewModel: ObservableObject, PayPalWebCheckoutDelegate {

    @Published var state = PayPalWebState()

    var payPalWebCheckoutClient: PayPalWebCheckoutClient?

    let configManager = CoreConfigManager(domain: "PayPalWeb Payments")

    func createOrder(amount: String, selectedMerchantIntegration: MerchantIntegration, intent: String) async throws {
        // might need to pass in payee as payee object or as auth header

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        // TODO: might need to pass in payee as payee object or as auth header
        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: intent,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
        )

        do {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams, selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loaded(order)
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            }
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }

    func paymentButtonTapped(orderID: String, funding: PayPalWebCheckoutFundingSource) {
        checkoutWithPayPal(orderID: orderID, funding: funding)
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
                state.checkoutResultResponse = .error(message: error.localizedDescription)
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

    func paypalWebCheckoutSuccessResult(checkoutResult: PayPalWebState.CheckoutResult) {
        DispatchQueue.main.async {
            self.state.checkoutResultResponse = .loaded(checkoutResult)
        }
    }

    func paypalWebCheckoutFailureResult(checkoutError: CorePayments.CoreSDKError) {
        DispatchQueue.main.async {
            self.state.checkoutResultResponse = .error(message: checkoutError.localizedDescription)
        }
    }

    func completeOrder(with intent: Intent, orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        switch intent {
        case .capture:
            try await captureOrder(orderID: orderID, selectedMerchantIntegration: selectedMerchantIntegration)
            print("Order Captured. ID: \(state.capturedOrder?.id ?? "")")
        case .authorize:
            try await authorizeOrder(orderID: orderID, selectedMerchantIntegration: selectedMerchantIntegration)
            print("Order Authorized. ID: \(state.authorizedOrder?.id ?? "")")
        }
    }

    func captureOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.captureOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func authorizeOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.authorizeOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error authorizing order: \(error.localizedDescription)")
        }
    }

    // MARK: - PayPalWeb Checkout Delegate

    func payPal(
        _ payPalClient: PayPalWebPayments.PayPalWebCheckoutClient,
        didFinishWithResult result: PayPalWebPayments.PayPalWebCheckoutResult
    ) {
        paypalWebCheckoutSuccessResult(checkoutResult: PayPalWebState.CheckoutResult(id: result.orderID, payerID: result.payerID))
    }

    func payPal(_ payPalClient: PayPalWebPayments.PayPalWebCheckoutClient, didFinishWithError error: CorePayments.CoreSDKError) {
        paypalWebCheckoutFailureResult(checkoutError: error)
    }

    func payPalDidCancel(_ payPalClient: PayPalWebPayments.PayPalWebCheckoutClient) {
        print("PayPal Checkout Canceled")
    }
}
