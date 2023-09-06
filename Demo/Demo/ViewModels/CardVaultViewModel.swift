import UIKit
import CardPayments
import CorePayments

class CardVaultViewModel: ObservableObject, CardVaultDelegate {

    @Published var state = CardVaultState()

    func getSetupToken(
        customerID: String? = nil,
        selectedMerchantIntegration: MerchantIntegration
    ) async throws {
        do {
            DispatchQueue.main.async {
                self.state.setupTokenResponse = .loading
            }
            let setupTokenResult = try await DemoMerchantAPI.sharedService.getSetupToken(
                customerID: customerID,
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.setupTokenResponse = .loaded(setupTokenResult)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.setupTokenResponse = .error(message: error.localizedDescription)
            }
            throw error
        }
    }

    func resetState() {
        state = CardVaultState()
    }

    func getPaymentToken(
        setupToken: String,
        selectedMerchantIntegration: MerchantIntegration
    ) async throws {
        do {
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = .loading
            }
            let paymentTokenResult = try await DemoMerchantAPI.sharedService.getPaymentToken(
                setupToken: setupToken,
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = .loaded(paymentTokenResult)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = .error(message: error.localizedDescription)
            }
            throw error
        }
    }

    func vault(config: CoreConfig, card: Card, setupToken: String) async {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .loading
        }
            let cardClient = CardClient(config: config)
            cardClient.vaultDelegate = self
            let cardVaultRequest = CardVaultRequest(card: card, setupTokenID: setupToken)
            cardClient.vault(cardVaultRequest)
    }

    func createOrder(amount: String, selectedMerchantIntegration: MerchantIntegration, intent: String) async throws {
        // might need to pass in payee as payee object or as auth header

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        // TODO: might need to pass in payee as payee object or as auth header
        let orderRequestParams = CreateOrderParams(
            intent: intent,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
        )

        do {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams,
                selectedMerchantIntegration: selectedMerchantIntegration
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
            let paymentTokenSource = PaymentTokenPaymentSource(
                paymentSource: PaymentTokenPaymentSource.TokenDetails(
                    token: PaymentTokenPaymentSource.Token(
                        id: state.paymentToken?.id ?? "",
                        type: "PAYMENT_METHOD_TOKEN"
                    )
                )
            )
            let order = try await DemoMerchantAPI.sharedService.captureOrderWithPaymentToken(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                bodyParams: paymentTokenSource
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
            let paymentTokenSource = PaymentTokenPaymentSource(
                paymentSource: PaymentTokenPaymentSource.TokenDetails(
                    token: PaymentTokenPaymentSource.Token(
                        id: state.paymentToken?.id ?? "",
                        type: "PAYMENT_METHOD_TOKEN"
                    )
                )
            )
            let order = try await DemoMerchantAPI.sharedService.authorizeOrderWithPaymentToken(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                bodyParams: paymentTokenSource
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

    func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }

    func setUpTokenSuccessResult(vaultResult: CardPayments.CardVaultResult) {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .loaded(
                CardVaultState.UpdateSetupTokenResult(id: vaultResult.setupTokenID, status: vaultResult.status)
            )
        }
    }

    func setUpdateSetupTokenFailureResult(vaultError: CorePayments.CoreSDKError) {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .error(message: vaultError.localizedDescription)
        }
    }

    // MARK: - CardVault Delegate

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultResult vaultResult: CardPayments.CardVaultResult) {
        print("vaultResult: \(vaultResult)")
        setUpTokenSuccessResult(vaultResult: vaultResult)
    }

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        print("error: \(vaultError.errorDescription ?? "")")
        setUpdateSetupTokenFailureResult(vaultError: vaultError)
    }
}
