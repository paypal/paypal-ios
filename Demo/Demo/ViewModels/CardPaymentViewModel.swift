import Foundation
import UIKit
import CardPayments
import CorePayments

class CardPaymentViewModel: ObservableObject, CardDelegate {

    @Published var state = CardPaymentState()

    let configManager = CoreConfigManager(domain: "Card Payments")

    private var cardClient: CardClient?

    func createOrder(
        amount: String,
        selectedMerchantIntegration: MerchantIntegration,
        intent: String,
        shouldVault: Bool,
        customerID: String? = nil
    ) async throws {

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        // TODO: might need to pass in payee as payee object or as auth header

        var vaultCardPaymentSource: VaultCardPaymentSource?
        if shouldVault {
            var customer: Customer?
            if let customerID {
                customer = Customer(id: customerID)
            }
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS"), customer: customer)
            let card = VaultCard(attributes: attributes)
            vaultCardPaymentSource = VaultCardPaymentSource(card: card)
        }

        var vaultPaymentSource: VaultPaymentSource?
        if let vaultCardPaymentSource {
            vaultPaymentSource = .card(vaultCardPaymentSource)
        }

        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: intent,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: vaultPaymentSource
        )

        do {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams, selectedMerchantIntegration: selectedMerchantIntegration
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
            let order = try await DemoMerchantAPI.sharedService.captureOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration
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
            let order = try await DemoMerchantAPI.sharedService.authorizeOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration
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

    func checkoutWith(card: Card, orderID: String, sca: SCA) async {
        openURL(orderID: orderID, clientID: "AcXwOk3dof7NCNcriyS8RVh5q39ozvdWUF9oHPrWqfyrDS4AwVdKe32Axuk2ADo6rI_31Vv6MGgOyzRt")
        
//        do {
//            DispatchQueue.main.async {
//                self.state.approveResultResponse = .loading
//            }
//            let config = try await configManager.getCoreConfig()
//            cardClient = CardClient(config: config)
//            cardClient?.delegate = self
//            let cardRequest = CardRequest(orderID: orderID, card: card, sca: sca)
//            cardClient?.approveOrder(request: cardRequest)
//        } catch {
//            self.state.approveResultResponse = .error(message: error.localizedDescription)
//            print("failed in checkout with card. \(error.localizedDescription)")
//        }
    }

    func openURL(orderID: String, clientID: String) {
        
        // swiftlint:disable line_length
        let urlString = "https://www.sandbox.paypal.com/checkoutnow?sessionID=uid_d306d7f713_mja6ndi6mjy&buttonSessionID=uid_ff19733906_mja6ndi6mjy&stickinessID=uid_945a0b22e7_mtg6mzi6ntq&smokeHash=&sign_out_user=false&fundingSource=venmo&buyerCountry=US&locale.x=en_US&commit=true&client-metadata-id=uid_d306d7f713_mja6ndi6mjy&enableFunding.0=venmo&clientID=\(clientID)&env=sandbox&sdkMeta=eyJ1cmwiOiJodHRwczovL3d3dy5wYXlwYWwuY29tL3Nkay9qcz9jbGllbnQtaWQ9QWNYd09rM2RvZjdOQ05jcml5UzhSVmg1cTM5b3p2ZFdVRjlvSFByV3FmeXJEUzRBd1ZkS2UzMkF4dWsyQURvNnJJXzMxVnY2TUdnT3l6UnQmY3VycmVuY3k9VVNEJmVuYWJsZS1mdW5kaW5nPXZlbm1vIiwiYXR0cnMiOnsiZGF0YS11aWQiOiJ1aWRfdHdva3VsenJqbW9hY3BwaXNrbW1rbGRrZ2txeHhlIn19&xcomponent=1&version=5.0.429&token=\(orderID)&redirect_uri=https://contoso.com/"
        //let urlString = "https://www.sandbox.paypal.com/smart/checkout/venmo?orderID=\(orderID)"
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string: urlString)!) { success in
                if success {
                    print(success)
                }
            }
        }
    }
    
    func approveResultSuccessResult(approveResult: CardPaymentState.CardResult) {
        DispatchQueue.main.async {
            self.state.approveResultResponse = .loaded(
                approveResult
            )
        }
    }

    func setUpdateSetupTokenFailureResult(vaultError: CorePayments.CoreSDKError) {
        DispatchQueue.main.async {
            self.state.approveResultResponse = .error(message: vaultError.localizedDescription)
        }
    }

    // MARK: - Card Delegate

    func card(_ cardClient: CardPayments.CardClient, didFinishWithResult result: CardPayments.CardResult) {
        approveResultSuccessResult(
            approveResult: CardPaymentState.CardResult(
                id: result.orderID,
                status: result.status,
                didAttemptThreeDSecureAuthentication: result.didAttemptThreeDSecureAuthentication
            )
        )
    }

    func card(_ cardClient: CardPayments.CardClient, didFinishWithError error: CorePayments.CoreSDKError) {
        print("Error here")
        DispatchQueue.main.async {
            self.state.approveResultResponse = .error(message: error.localizedDescription)
        }
    }

    func cardDidCancel(_ cardClient: CardPayments.CardClient) {
        print("Card Payment Canceled")
        DispatchQueue.main.async {
            self.state.approveResultResponse = .idle
            self.state.approveResult = nil
        }
    }

    func cardThreeDSecureWillLaunch(_ cardClient: CardPayments.CardClient) {
        print("About to launch 3DS")
    }

    func cardThreeDSecureDidFinish(_ cardClient: CardPayments.CardClient) {
        print("Finished 3DS")
    }
}
