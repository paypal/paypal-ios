import Foundation
import CorePayments
import PayPalWebPayments
import FraudProtection

class PayPalWebViewModel: ObservableObject {

    @Published var state = PayPalPaymentState()
    @Published var intent: Intent = .authorize
    @Published var order: Order?
    @Published var checkoutResult: PayPalWebCheckoutResult?

    var payPalWebCheckoutClient: PayPalWebCheckoutClient?

    var orderID: String? {
        order?.id
    }

    let configManager = CoreConfigManager(domain: "PayPalWeb Payments")
    private var payPalDataCollector: PayPalDataCollector?

    func createOrder(shouldVault: Bool) async throws {
        let amountRequest = Amount(currencyCode: "USD", value: "10.00")

        // TODO: might need to pass in payee as payee object or as auth header
        var vaultPayPalPaymentSource: VaultPayPalPaymentSource?
        if shouldVault {
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS", usageType: "MERCHANT", customerType: "CONSUMER"))
            // The returnURL is not used in our mobile SDK, but a required field for create order with PayPal payment source. DTPPCPSDK-1492 to track this issue
            let paypal = VaultPayPal(
                attributes: attributes,
                experienceContext: ExperienceContext(
                    returnURL: "https://example.com/returnUrl",
                    cancelURL: "https://example.com/cancelUrl"
                )
            )
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
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams,
                selectedMerchantIntegration: DemoSettings.merchantIntegration
            )
            DispatchQueue.main.async {
                self.order = order
                self.state.createdOrderResponse = .loaded(order)
            }
            print("✅ fetched orderID: \(order.id) with status: \(order.status)")
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
            }
            print("❌ failed to fetch orderID with error: \(error.localizedDescription)")
        }
    }

    func paymentButtonTapped(funding: PayPalWebCheckoutFundingSource) {
        Task {
            do {
                DispatchQueue.main.async {
                    self.state.approveResultResponse = .loading
                }
                payPalWebCheckoutClient = try await getPayPalClient()
                guard let payPalWebCheckoutClient else {
                    print("Error initializing PayPalWebCheckoutClient")
                    return
                }

                if let orderID = state.createOrder?.id {
                    let payPalRequest = PayPalWebCheckoutRequest(orderID: orderID, fundingSource: funding)
                    payPalWebCheckoutClient.start(request: payPalRequest) { result in
                        switch result {
                        case .success(let paypalResult):
                            DispatchQueue.main.async {
                                self.state.approveResultResponse = .loaded(
                                    PayPalPaymentState.ApprovalResult(id: paypalResult.orderID, status: "APPROVED")
                                )
                                self.checkoutResult = paypalResult
                                print("✅ Checkout result: \(String(describing: paypalResult))")
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                if error == PayPalError.checkoutCanceledError {
                                    print("Canceled")
                                    self.state.approveResultResponse = .idle
                                } else {
                                    self.state.approveResultResponse = .error(message: error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error starting PayPalWebCheckoutClient")
                DispatchQueue.main.async {
                    self.state.createdOrderResponse = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func getPayPalClient() async throws -> PayPalWebCheckoutClient? {
        do {
            let config = try await configManager.getCoreConfig()
            let payPalClient = PayPalWebCheckoutClient(config: config)
            payPalDataCollector = PayPalDataCollector(config: config)
            return payPalClient
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
            }
            print("❌ failed to create PayPalWebCheckoutClient with error: \(error.localizedDescription)")
            return nil
        }
    }

    func completeTransaction() async throws {
        do {
            setLoadingState()
            if let orderID = state.createOrder?.id {
                let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
                let order = try await DemoMerchantAPI.sharedService.completeOrder(
                    intent: intent,
                    orderID: orderID,
                    payPalClientMetadataID: payPalClientMetadataID
                )
                setOrderCompletionLoadedState(order: order)
            }
        } catch {
            setErrorState(message: error.localizedDescription)
            print("Error with \(intent) order: \(error.localizedDescription)")
        }
    }
    
    private func setLoadingState() {
        DispatchQueue.main.async {
            switch self.intent {
            case .authorize:
                self.state.authorizedOrderResponse = .loading
            case .capture:
                self.state.capturedOrderResponse = .loading
            }
        }
    }
    
    private func setOrderCompletionLoadedState(order: Order) {
        DispatchQueue.main.async {
            switch self.intent {
            case .authorize:
                self.state.authorizedOrderResponse = .loaded(order)
            case .capture:
                self.state.capturedOrderResponse = .loaded(order)
            }
        }
    }
    
    private func setErrorState(message: String) {
        DispatchQueue.main.async {
            switch self.intent {
            case .authorize:
                self.state.authorizedOrderResponse = .error(message: message)
            case .capture:
                self.state.capturedOrderResponse = .error(message: message)
            }
        }
    }

    func resetState() {
        self.state = PayPalPaymentState()
        order = nil
        checkoutResult = nil
    }
}
