import Foundation
import CorePayments
import VenmoPayments

@MainActor
class VenmoViewModel: ObservableObject {

    @Published var state = VenmoPaymentState()
    @Published var intent: Intent = .authorize

    private let configManager = CoreConfigManager(domain: "Venmo Payments")

    private var venmoClient: VenmoClient?

    /// Callback host for app switch, resolved from the environment selected in Demo settings.
    private var returnURL: String { DemoSettings.environment.returnBaseURL }

    func checkout(amount: String) async {
        state = VenmoPaymentState()
        state.createdOrderResponse = .loading

        let order: Order
        do {
            order = try await fetchOrder(amount: amount)
        } catch {
            state.createdOrderResponse = .error(message: error.localizedDescription)
            return
        }
        state.createdOrderResponse = .loaded(order)
        state.approveResultResponse = .loading

        let client = VenmoClient(config: configManager.getCoreConfig())
        venmoClient = client

        do {
            let result = try await client.start(orderID: order.id)
            state.approveResultResponse = .loaded(
                VenmoPaymentState.ApprovalResult(id: result.orderID, payerID: result.payerID)
            )
        } catch {
            if VenmoError.isCheckoutCanceled(error) {
                state.approveResultResponse = .error(message: "Venmo checkout was canceled.")
            } else {
                state.approveResultResponse = .error(message: error.localizedDescription)
            }
        }
    }

    func completeTransaction() async {
        guard let orderID = state.createOrder?.id else { return }
        state.completedOrderResponse = .loading
        do {
            let order = try await DemoMerchantAPI.shared.completeOrder(
                intent: intent,
                orderID: orderID,
                clientMetadataID: nil
            )
            state.completedOrderResponse = .loaded(order)
        } catch {
            state.completedOrderResponse = .error(message: error.localizedDescription)
        }
    }

    func handleReturnURL(_ url: URL) {
        venmoClient?.handleReturnURL(url)
    }

    func resetState() {
        state = VenmoPaymentState()
    }

    private func fetchOrder(amount: String) async throws -> Order {
        let experience = VenmoExperienceContext(
            returnUrl: "\(returnURL)/success",
            cancelUrl: "\(returnURL)/cancel",
            appSwitchContext: VenmoAppSwitchContext()
        )
        let params = CreateOrderParams(
            intent: intent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: Amount(currencyCode: "USD", value: amount.isEmpty ? "10.00" : amount))],
            paymentSource: .venmo(OrderVenmoPaymentSource(venmo: VenmoSource(experienceContext: experience)))
        )
        return try await DemoMerchantAPI.shared.createOrder(
            orderParams: params,
            integration: DemoSettings.merchantIntegration
        )
    }
}
