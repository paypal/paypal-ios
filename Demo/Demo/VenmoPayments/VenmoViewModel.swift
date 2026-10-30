import Foundation
import CorePayments
import VenmoPayments
import SwiftUI

@Observable
@MainActor
class VenmoViewModel: ObservableObject {
    
    let api = DemoMerchantAPI.shared
    var orderIntent: Intent = .authorize
    
    var createOrderState: AsyncState<Order> = .idle

    func createOrder(using request: DemoCreateOrderRequest) {
        orderIntent = request.intent
        createOrderState = .loading
        Task {
            let params = makeVenmoOrderParams(request: request)
            do {
                let order = try await api.createOrder(orderParams: params)
                createOrderState = .loaded(order)
            } catch {
                createOrderState = .error(message: error.localizedDescription)
            }
        }
    }

    func checkout(amount: String) async {
    }

    func completeTransaction() async {
    }

    func handleReturnURL(_ url: URL) {
    }

    func resetState() {
    }

    private func fetchOrder(amount: String) async throws -> Order {
        throw NSError(domain: "TODO: implement", code: 123)
    }
    
    private func makeVenmoOrderParams(request: DemoCreateOrderRequest) -> CreateOrderParams {
        let returnURL: String = DemoSettings.environment.returnBaseURL
        let experience = VenmoExperienceContext(
            returnUrl: "\(returnURL)/success",
            cancelUrl: "\(returnURL)/cancel",
            appSwitchContext: VenmoAppSwitchContext()
        )
        let amountValue = request.amount.isEmpty ? "10.00" : request.amount
        return CreateOrderParams(
            intent: orderIntent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: Amount(currencyCode: "USD", value: amountValue))],
            paymentSource: .venmo(OrderVenmoPaymentSource(venmo: VenmoSource(experienceContext: experience)))
        )
    }
}
