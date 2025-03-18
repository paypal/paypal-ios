import Foundation
import CorePayments
import PayPalBrandedCardForm
import FraudProtection

class BrandedCardFormViewModel: ObservableObject {

    @Published var state = CardFormState()
    @Published var intent: Intent = .authorize
    @Published var order: Order?
    @Published var checkoutResult: CardFormResult?

    var cardFormClient: PayPalBrandedCardFormClient?

    var orderID: String? {
        order?.id
    }

    let configManager = CoreConfigManager(domain: "PayPal Branded Card Form")
    private var payPalDataCollector: PayPalDataCollector?

    func createOrder() async throws {
        // TODO: vault with purchase
        let amountRequest = Amount(currencyCode: "USD", value: "10.00")

        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: intent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
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

    func paymentButtonTapped() {
        Task {
            do {
                DispatchQueue.main.async {
                    self.state.approveResultResponse = .loading
                }
                cardFormClient = try await getPayPalClient()
                guard let cardFormClient else {
                    print("Error initializing PayPalWebCheckoutClient")
                    return
                }

                if let orderID = state.createOrder?.id {
                    cardFormClient.start(orderID: orderID) { result in
                        switch result {
                        case .success(let paypalResult):
                            DispatchQueue.main.async {
                                self.state.approveResultResponse = .loaded(
                                    CardFormState.ApprovalResult(id: paypalResult.orderID, status: "APPROVED")
                                )
                                self.checkoutResult = paypalResult
                                print("✅ Checkout result: \(String(describing: paypalResult))")
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                if error == CardFormError.checkoutCanceledError {
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

    func getPayPalClient() async throws -> PayPalBrandedCardFormClient? {
        do {
            let config = try await configManager.getCoreConfig()
            let payPalClient = PayPalBrandedCardFormClient(config: config)
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
        self.state = CardFormState()
        order = nil
        checkoutResult = nil
    }
}
