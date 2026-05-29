import Foundation
import CorePayments
import VenmoPayments

@MainActor
class VenmoViewModel: ObservableObject {

    @Published var state = VenmoPaymentState()
    @Published var order: Order?
    @Published var checkoutResult: VenmoCheckoutResult?

    var venmoClient: VenmoClient?

    let configManager = CoreConfigManager(domain: "Venmo Payments")

    func createOrder() async {
        let amountRequest = Amount(currencyCode: "USD", value: "10.00")

        let params = CreateOrderParams(
            applicationContext: nil,
            intent: Intent.capture.rawValue,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: nil
        )

        do {
            state.createdOrderResponse = .loading
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: params,
                selectedMerchantIntegration: DemoSettings.merchantIntegration
            )
            self.order = order
            state.createdOrderResponse = .loaded(order)
            print("Fetched orderID: \(order.id) with status: \(order.status)")
        } catch {
            state.createdOrderResponse = .error(message: error.localizedDescription)
            print("Failed to create order: \(error.localizedDescription)")
        }
    }

    func venmoButtonTapped() {
        Task {
            do {
                state.approveResultResponse = .loading
                venmoClient = try await getVenmoClient()

                guard let venmoClient else {
                    state.approveResultResponse = .error(message: "Error initializing VenmoClient")
                    return
                }

                if let orderID = state.createOrder?.id {
                    let request = VenmoCheckoutRequest(orderID: orderID)
                    let venmoResult = try await venmoClient.start(request)
                    state.approveResultResponse = .loaded(
                        VenmoPaymentState.ApprovalResult(id: venmoResult.orderID, status: "APPROVED")
                    )
                    checkoutResult = venmoResult
                    print("Venmo checkout result: orderID=\(venmoResult.orderID), payerID=\(venmoResult.payerID)")
                }
            } catch {
                if VenmoError.isCheckoutCanceled(error) {
                    print("Venmo checkout canceled")
                    state.approveResultResponse = .idle
                } else {
                    state.approveResultResponse = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func getVenmoClient() async throws -> VenmoClient? {
        do {
            let config = try await configManager.getCoreConfig()
            return VenmoClient(config: config)
        } catch {
            state.createdOrderResponse = .error(message: error.localizedDescription)
            print("Failed to create VenmoClient: \(error.localizedDescription)")
            return nil
        }
    }

    func completeTransaction() async {
        do {
            state.capturedOrderResponse = .loading
            if let orderID = state.createOrder?.id {
                let order = try await DemoMerchantAPI.sharedService.completeOrder(
                    intent: .capture,
                    orderID: orderID
                )
                state.capturedOrderResponse = .loaded(order)
            }
        } catch {
            state.capturedOrderResponse = .error(message: error.localizedDescription)
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func resetState() {
        state = VenmoPaymentState()
        order = nil
        checkoutResult = nil
    }

    func handleReturnURL(_ url: URL) {
        guard let venmoClient else { return }
        venmoClient.handleReturnURL(url)
    }
}
