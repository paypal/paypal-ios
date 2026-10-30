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
    var checkoutState: AsyncState<VenmoCheckoutResult> = .idle
    var completeOrderState: AsyncState<Order> = .idle

    private let venmoClient: VenmoClient

    init() {
        let configManager = CoreConfigManager(domain: "Venmo Payments")
        let config = configManager.getCoreConfig()
        venmoClient = VenmoClient(config: config)
    }

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
    
    func startVenmoCheckout() {
        guard let orderID = createOrderState.value?.id else {
            checkoutState = .error(message: "Order ID Required.")
            return
        }
        
        Task {
            do {
                let result = try await venmoClient.start(orderID: orderID)
                checkoutState = .loaded(result)
            } catch {
                if VenmoError.isCheckoutCanceled(error) {
                    checkoutState = .error(message: "Venmo checkout was canceled.")
                } else {
                    checkoutState = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func completeOrder() {
        guard let orderID = createOrderState.value?.id else {
            completeOrderState = .error(message: "Order ID Required.")
            return
        }
        
        completeOrderState = .loading
        Task {
            do {
                let completedOrder: Order
                switch orderIntent {
                case .capture:
                    completedOrder = try await api.captureOrder(orderID: orderID)
                case .authorize:
                    completedOrder = try await api.authorizeOrder(orderID: orderID)
                }
                completeOrderState = .loaded(completedOrder)
            } catch {
                print("Error capturing order: \(error.localizedDescription)")
                completeOrderState = .error(message: error.localizedDescription)
            }
        }
    }

    func handleReturnURL(_ url: URL) {
        venmoClient.handleReturnURL(url)
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
