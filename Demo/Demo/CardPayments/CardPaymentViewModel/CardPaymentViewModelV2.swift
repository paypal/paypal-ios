import Foundation
import CardPayments
import FraudProtection

private let millisPerNanosecond: UInt64 = 1000000

private func animationDelay() async {
    do {
        try await Task.sleep(nanoseconds: millisPerNanosecond * 250)
    } catch {
        // do nothing
    }
}

@MainActor
class CardPaymentViewModelV2: ObservableObject {
    
    @Published var createOrderState: LoadingState<Order> = .idle
    @Published var approveOrderResult: LoadingState<CardPaymentView.CardResult> = .idle
    @Published var captureAuthorizeResult: LoadingState<Order> = .idle
    @Published var stepNumber: Int = 0

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
        Task {
            do {
                createOrderState = .loading
                let order = try await DemoMerchantAPI.sharedService.createOrder(
                    orderParams: orderRequestParams, selectedMerchantIntegration: DemoSettings.merchantIntegration
                )
                createOrderState = .loaded(order)
            } catch {
                createOrderState = .error(message: error.localizedDescription)
            }
            await animationDelay()
            stepNumber += 1
        }
    }
    
    func approveOrder(using request: DemoApproveOrderRequest) {
        guard let orderID = createOrderState.value?.id else {
            approveOrderResult = .error(message: "Order ID Required.")
            return
        }
        Task {
            do {
                approveOrderResult = .loading
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
                let mappedResult = CardPaymentView.CardResult(
                    id: result.orderID,
                    status: result.status,
                    didAttemptThreeDSecureAuthentication: result.didAttemptThreeDSecureAuthentication
                )
                
                // TODO: figure out a way to make CardClient non-null
                self.cardClient = cardClient
                approveOrderResult = .loaded(mappedResult)
            } catch {
                print("failed in checkout with card. \(error.localizedDescription)")
                // TODO: differentiate error from cancellation state
                approveOrderResult = .error(message: error.localizedDescription)
            }
            await animationDelay()
            stepNumber += 1
        }
    }
    
    func completeOrder(intent: Intent) {
        guard let order = createOrderState.value else {
            captureAuthorizeResult = .error(message: "Order ID Required.")
            return
        }
        Task {
            captureAuthorizeResult = .loading
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
                captureAuthorizeResult = .loaded(completedOrder)
            } catch {
                print("Error capturing order: \(error.localizedDescription)")
                captureAuthorizeResult = .error(message: error.localizedDescription)
            }
            await animationDelay()
            stepNumber += 1
        }
    }
}
