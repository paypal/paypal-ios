import Foundation
import CardPayments
import FraudProtection

@MainActor
@Observable
class CardPaymentViewModel {
    
    let uiState = CardPaymentUiState()
    
    var createOrderRequest: DemoCreateOrderRequest {
        get { uiState.createOrderRequest }
        set { uiState.createOrderRequest = newValue }
    }
    
    var approveOrderRequest: DemoApproveOrderRequest {
        get { uiState.approveOrderRequest }
        set { uiState.approveOrderRequest = newValue }
    }
    
    var createOrderState: AsyncState<Order> {
        get { uiState.createOrderState }
        set { uiState.createOrderState = newValue }
    }
    
    var approveOrderState: AsyncState<CardResult> {
        get { uiState.approveOrderState }
        set { uiState.approveOrderState = newValue }
    }
    
    var completeOrderState: AsyncState<Order> {
        get { uiState.completeOrderState }
        set { uiState.completeOrderState = newValue }
    }
    
    // HACK: this is used to drive the scroll-to-bottom animation
    var stepCount: Int {
        if createOrderState.isIdleOrLoading {
            return 0
        }
        if approveOrderState.isIdleOrLoading {
            return 1
        }
        if completeOrderState.isIdleOrLoading {
            return 2
        }
        return 3
    }

    private var cardClient: CardClient?
    private var payPalDataCollector: PayPalDataCollector?

    let configManager = CoreConfigManager(domain: "Card Payments")

    func createOrder(using request: DemoCreateOrderRequest) {
        var vaultCardPaymentSource: VaultCardPaymentSource?
        if request.shouldVault {
            let customerID = request.vaultCustomerID
            let customer = customerID.isEmpty ? nil : Customer(id: customerID)
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS"), customer: customer)
            let card = VaultCard(attributes: attributes)
            vaultCardPaymentSource = VaultCardPaymentSource(card: card)
        }

        var vaultPaymentSource: VaultPaymentSource?
        if let vaultCardPaymentSource {
            vaultPaymentSource = .card(vaultCardPaymentSource)
        }

        // TODO: might need to pass in payee as payee object or as auth header
        let amountRequest = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: request.intent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: vaultPaymentSource
        )
        createOrderState = .loading
        Task {
            do {
                let order = try await DemoMerchantAPI.sharedService.createOrder(
                    orderParams: orderRequestParams, selectedMerchantIntegration: DemoSettings.merchantIntegration
                )
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
                let config = try await configManager.getCoreConfig()
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
                let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
                
                let completedOrder: Order
                switch intent {
                case .capture:
                    completedOrder = try await DemoMerchantAPI.sharedService.captureOrder(
                        orderID: order.id,
                        selectedMerchantIntegration: DemoSettings.merchantIntegration,
                        payPalClientMetadataID: payPalClientMetadataID
                    )
                case .authorize:
                    completedOrder = try await DemoMerchantAPI.sharedService.authorizeOrder(
                        orderID: order.id,
                        selectedMerchantIntegration: DemoSettings.merchantIntegration,
                        payPalClientMetadataID: payPalClientMetadataID
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
