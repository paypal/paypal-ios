import Foundation
import CorePayments
import VenmoPayments

@MainActor
class VenmoViewModel: ObservableObject {

    @Published var state = VenmoPaymentState()
    @Published var intent: Intent = .authorize
    @Published var order: Order?
    @Published var checkoutResult: VenmoCheckoutResult?

    var venmoClient: VenmoClient?

    var orderID: String? {
        order?.id
    }

    let configManager = CoreConfigManager(domain: "Venmo Payments")

    func createOrder() async throws {
        let amountRequest = Amount(currencyCode: "USD", value: "10.00")

        let params = CreateOrderParams(
            applicationContext: nil,
            intent: intent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: nil
        )

        do {
            DispatchQueue.main.async { self.state.createdOrderResponse = .loading }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: params,
                selectedMerchantIntegration: DemoSettings.merchantIntegration
            )
            DispatchQueue.main.async {
                self.order = order
                self.state.createdOrderResponse = .loaded(order)
            }
            print("Fetched orderID: \(order.id) with status: \(order.status)")
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
            }
            print("Failed to create order: \(error.localizedDescription)")
        }
    }

    func venmoButtonTapped() {
        Task {
            do {
                DispatchQueue.main.async {
                    self.state.approveResultResponse = .loading
                }
                venmoClient = try await getVenmoClient()
                guard let venmoClient else {
                    print("Error initializing VenmoClient")
                    return
                }

                if let orderID = state.createOrder?.id {
                    let request = VenmoCheckoutRequest(orderID: orderID)
                    let venmoResult = try await venmoClient.start(request)
                    DispatchQueue.main.async {
                        self.state.approveResultResponse = .loaded(
                            VenmoPaymentState.ApprovalResult(id: venmoResult.orderID, status: "APPROVED")
                        )
                        self.checkoutResult = venmoResult
                        print("Venmo checkout result: orderID=\(venmoResult.orderID), payerID=\(venmoResult.payerID)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    if VenmoError.isCheckoutCanceled(error) {
                        print("Venmo checkout canceled")
                        self.state.approveResultResponse = .idle
                    } else {
                        self.state.approveResultResponse = .error(message: error.localizedDescription)
                    }
                }
            }
        }
    }

    func getVenmoClient() async throws -> VenmoClient? {
        do {
            let config = try await configManager.getCoreConfig()
            return VenmoClient(config: config)
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
            }
            print("Failed to create VenmoClient: \(error.localizedDescription)")
            return nil
        }
    }

    func completeTransaction() async throws {
        do {
            setLoadingState()
            if let orderID = state.createOrder?.id {
                let order = try await DemoMerchantAPI.sharedService.completeOrder(
                    intent: intent,
                    orderID: orderID
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
        self.state = VenmoPaymentState()
        order = nil
        checkoutResult = nil
    }

    func handleReturnURL(_ url: URL) {
        guard let venmoClient else { return }
        venmoClient.handleReturnURL(url)
    }
}
