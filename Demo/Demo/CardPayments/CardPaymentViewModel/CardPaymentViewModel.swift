import Foundation
import CardPayments
import CorePayments
import FraudProtection

@MainActor
class CardPaymentViewModel: ObservableObject {

    @Published var state = CardPaymentState()
    private var payPalDataCollector: PayPalDataCollector?

    let configManager = CoreConfigManager(domain: "Card Payments")

    private var cardClient: CardClient?

    /// Card supports:
    /// - S1: no vault (paymentSource = nil)
    /// - S5: vault (paymentSource.card.attributes.vault)
    func createOrder(
        amount: String,
        selectedMerchantIntegration: MerchantIntegration,
        intent: String,
        shouldVault: Bool,
        customerID: String? = nil
    ) async throws {

        let amountRequest = Amount(currencyCode: "USD", value: amount)

        var paymentSource: OrderPaymentSource?
        if shouldVault {
            let customer = customerID.map { Customer(id: $0) }
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS"), customer: customer)
            let card = CardSource(attributes: attributes)
            paymentSource = .card(OrderCardPaymentSource(card: card))
        }

        let params = CreateOrderParams(
            intent: intent,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: paymentSource
        )

        do {
            DispatchQueue.main.async { self.state.createdOrderResponse = .loading }
            let order = try await DemoMerchantAPI.shared.createOrder(
                orderParams: params, selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loaded(order)
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            }
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }

    func captureOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loading
            }
            let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
            let order = try await DemoMerchantAPI.shared.captureOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                payPalClientMetadataID: payPalClientMetadataID
            )
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func authorizeOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loading
            }
            let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
            let order = try await DemoMerchantAPI.shared.authorizeOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                payPalClientMetadataID: payPalClientMetadataID
            )
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func checkoutWith(card: Card, orderID: String, sca: SCA) {
        DispatchQueue.main.async {
            self.state.approveResultResponse = .loading
        }
        let config = configManager.getCoreConfig()
        cardClient = CardClient(config: config)
        payPalDataCollector = PayPalDataCollector(config: config)
        let cardRequest = CardRequest(orderID: orderID, card: card, sca: sca)
        cardClient?.approveOrder(request: cardRequest) { result in
            switch result {
            case .success(let cardResult):
                self.setApprovalSuccessResult(
                    approveResult: CardPaymentState.CardResult(
                        id: cardResult.orderID,
                        status: cardResult.status,
                        didAttemptThreeDSecureAuthentication: cardResult.didAttemptThreeDSecureAuthentication
                    )
                )
            case .failure(let error):
                if error == CardError.threeDSecureCanceledError {
                    self.setApprovalCancelResult()
                } else {
                    self.setApprovalFailureResult(error: error)
                }
            }
        }
    }

    func setApprovalSuccessResult(approveResult: CardPaymentState.CardResult) {
        DispatchQueue.main.async {
            self.state.approveResultResponse = .loaded(
                approveResult
            )
        }
    }

    func setApprovalFailureResult(error: Error) {
        DispatchQueue.main.async {
            self.state.approveResultResponse = .error(message: error.localizedDescription)
        }
    }

    func setApprovalCancelResult() {
        print("Canceled")
        DispatchQueue.main.async {
            self.state.approveResultResponse = .idle
        }
    }
}
