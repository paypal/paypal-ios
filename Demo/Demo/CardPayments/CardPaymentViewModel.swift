import Foundation
import CardPayments
import FraudProtection

@MainActor
@Observable
class CardPaymentViewModel {
    
    let api = DemoMerchantAPI.shared
    let integration = DemoSettings.merchantIntegration

    // HACK: see if this information exists on the newly created order
    var orderIntent: Intent = .authorize
    
    private var cardClient: CardClient?
    private var payPalDataCollector: PayPalDataCollector?

    let configManager = CoreConfigManager(domain: "Card Payments")
    
    var createOrderState: AsyncState<Order> = .idle
    var approveOrderState: AsyncState<CardResult> = .idle
    var completeOrderState: AsyncState<Order> = .idle
    
    // this is used to track changes and drive the scroll-to-bottom animation
    var stateHash: Int {
        var hasher = Hasher()
        hasher.combine(createOrderState)
        hasher.combine(approveOrderState)
        hasher.combine(completeOrderState)
        return hasher.finalize()
    }

    func createOrder(using request: DemoCreateOrderRequest) {
        // HACK: keep a record of the intent (unless we can get it from the create order state var)
        orderIntent = request.intent
        
        var vaultCardPaymentSource: OrderCardPaymentSource?
        if request.shouldVault {
            let customerID = request.vaultCustomerID
            let customer = customerID.isEmpty ? nil : Customer(id: customerID)
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS"), customer: customer)
            let card = CardSource(attributes: attributes)
            vaultCardPaymentSource = OrderCardPaymentSource(card: card)
        }

        var vaultPaymentSource: OrderPaymentSource?
        if let vaultCardPaymentSource {
            vaultPaymentSource = .card(vaultCardPaymentSource)
        }

        // TODO: might need to pass in payee as payee object or as auth header
        let amountRequest = Amount(currencyCode: "USD", value: "10.00")
        let params = CreateOrderParams(
            intent: request.intent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: vaultPaymentSource
        )
        createOrderState = .loading
        Task {
            do {
                let order = try await api.createOrder(orderParams: params, integration: integration)
                createOrderState = .loaded(order)
            } catch {
                createOrderState = .error(message: error.localizedDescription)
            }
        }
    }
    
    func approveOrder(using request: DemoApproveOrderRequest) {
        guard let orderID = createOrderState.value?.id else {
            approveOrderState = .error(message: "Order ID Required.")
            return
        }
        approveOrderState = .loading
        Task {
            do {
                let config = configManager.getCoreConfig()
                let cardClient = CardClient(config: config)
                payPalDataCollector = PayPalDataCollector(config: config)
                
                let card = Card.createCard(
                    cardNumber: request.cardNumber,
                    expirationDate: request.cardExpirationDate,
                    cvv: request.cardCVV
                )
                let cardRequest = CardRequest(orderID: orderID, card: card, sca: request.sca)
                let result = try await cardClient.approveOrder(request: cardRequest)
                approveOrderState = .loaded(result)
                
                // update card client reference
                // TODO: make CardClient non-null
                self.cardClient = cardClient
            } catch {
                print("failed in checkout with card. \(error.localizedDescription)")
                // TODO: differentiate error from cancellation state
                approveOrderState = .error(message: error.localizedDescription)
            }
        }
    }
    
    func completeOrder(intent: Intent) {
        guard let order = createOrderState.value else {
            completeOrderState = .error(message: "Order ID Required.")
            return
        }
        completeOrderState = .loading
        Task {
            do {
                let clientMetadataID = payPalDataCollector?.collectDeviceData()
                
                let completedOrder: Order
                switch intent {
                case .capture:
                    completedOrder = try await api.captureOrder(
                        orderID: order.id,
                        integration: integration,
                        clientMetadataID: clientMetadataID
                    )
                case .authorize:
                    completedOrder = try await api.authorizeOrder(
                        orderID: order.id,
                        integration: DemoSettings.merchantIntegration,
                        clientMetadataID: clientMetadataID
                    )
                }
                completeOrderState = .loaded(completedOrder)
            } catch {
                print("Error capturing order: \(error.localizedDescription)")
                completeOrderState = .error(message: error.localizedDescription)
            }
        }
    }
}
