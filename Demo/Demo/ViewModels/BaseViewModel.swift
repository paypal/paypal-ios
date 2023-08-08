import UIKit
import CardPayments
import PayPalWebPayments
import CorePayments
import AuthenticationServices
import PayPalNativePayments
import PayPalCheckout

/// This class is used to share the orderID across shared views, update the text of `bottomStatusLabel` in our `FeatureBaseViewController`
/// as well as share the logic of `processOrder` across our duplicate (SwiftUI and UIKit) card views.
class BaseViewModel: ObservableObject, PayPalWebCheckoutDelegate, CardDelegate {

    /// Weak reference to associated view
    weak var view: FeatureBaseViewController?
    var payPalWebCheckoutClient: PayPalWebCheckoutClient?

    /// order ID shared across views
    @Published var orderID: String?
    @Published var selectedMerchantIntegration: MerchantIntegration = .unspecified

    // MARK: - Init

    init(view: FeatureBaseViewController? = nil) {
        self.view = view
    }

    // MARK: - Helper Functions

    func updateTitle(_ message: String) {
        DispatchQueue.main.async {
            self.view?.bottomStatusLabel.text = message
        }
    }

    func updateOrderID(with orderID: String) {
        DispatchQueue.main.async {
            self.orderID = orderID
        }
    }

    func createOrder(amount: String?, selectedMerchantIntegration: MerchantIntegration) async -> String? {
        // might need to pass in payee as payee object or as auth header
        updateTitle("Creating order...")
        guard let amount = amount else { return nil }

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        // TODO: might need to pass in payee as payee object or as auth header
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
        )

        do {
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams, selectedMerchantIntegration: selectedMerchantIntegration
            )
            updateTitle("Order ID: \(order.id)")
            updateOrderID(with: order.id)
            print("✅ fetched orderID: \(order.id) with status: \(order.status)")
        } catch {
            updateTitle("Your order has failed, please try again")
            print("❌ failed to fetch orderID: \(error)")
        }
        return orderID
    }

    // MARK: Card Module Integration

    func createCard(cardNumber: String?, expirationDate: String?, cvv: String?) -> Card? {
        guard let cardNumber = cardNumber, let expirationDate = expirationDate, let cvv = cvv else {
            updateTitle("Failed: missing card / orderID.")
            return nil
        }

        let cleanedCardText = cardNumber.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDate.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return Card(number: cleanedCardText, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvv)
    }
    
    func createVaultCard(cardNumber: String?, expirationDate: String?, cvv: String?) -> VaultCard? {
        guard let cardNumber = cardNumber, let expirationDate = expirationDate, let cvv = cvv else {
            updateTitle("Failed: missing card / orderID.")
            return nil
        }

        let cleanedCardText = cardNumber.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDate.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return VaultCard(number: cleanedCardText, expiry: "\(expirationYear)-\(expirationMonth)", securityCode: cvv)
    }

    func checkoutWith(
        card: Card,
        orderID: String,
        shouldVault: Bool = false,
        customerID: String? = nil
    ) async {
        guard let config = await getCoreConfig() else {
            return
        }
        let cardClient = CardClient(config: config)
        cardClient.delegate = self
        let vault = shouldVault ? Vault(customerID: customerID) : nil
        let cardRequest = CardRequest(orderID: orderID, card: card, sca: .scaAlways, vault: vault)
        cardClient.approveOrder(request: cardRequest)
    }
    
    func vaultCard(
        card: VaultCard,
        customerID: String? = nil
    ) async {
        do {
            guard let config = await getCoreConfig() else {
                return
            }
            let cardClient = CardClient(config: config)
            let tokenResponse = try await DemoMerchantAPI.sharedService.getSetupToken(
                customerID: customerID, selectedMerchantIntegration: selectedMerchantIntegration
            )
            if let tokenResponse {
                let cardVaultRequest = CardVaultRequest(card: card, setupToken: tokenResponse.id)
                cardClient.vault(vaultRequest: cardVaultRequest)
            }
        } catch {
            print("Error in getSetupToken: \(error.localizedDescription)")
        }
    }

    func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        guard orderID != nil else {
            updateTitle("Create an order to proceed")
            return false
        }

        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }

    // MARK: - PayPal Module Integration

    func paymentButtonTapped(funding: PayPalWebCheckoutFundingSource) {
        guard let orderID = orderID else {
            self.updateTitle("Failed: missing orderID.")
            return
        }

        checkoutWithPayPal(orderID: orderID, funding: funding)
    }
    
    func checkoutWithPayPal(
        orderID: String,
        funding: PayPalWebCheckoutFundingSource
    ) {
        Task {
            do {
                payPalWebCheckoutClient = try await getPayPalClient()
                payPalWebCheckoutClient?.delegate = self
                guard let client = payPalWebCheckoutClient else {
                    print("Error in initializing paypal webcheckout client")
                    return
                }
                let payPalRequest = PayPalWebCheckoutRequest(orderID: orderID, fundingSource: funding)
                client.start(request: payPalRequest)
            } catch {
                print("Error in starting paypal webcheckout client")
            }
        }
    }

    // MARK: - PayPal Delegate

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult) {
        updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: CONFIRMED")
        print("✅ Order is successfully approved and ready to be captured/authorized with result: \(result)")
    }

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
        print("❌ There was an error: \(error)")
    }

    func payPalDidCancel(_ payPalClient: PayPalWebCheckoutClient) {
        updateTitle("\(DemoSettings.intent) cancelled")
        print("❌ Buyer has cancelled the PayPal flow")
    }

    // MARK: - Card Delegate

    func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
        let intent = DemoSettings.intent.rawValue.uppercased()
        if intent == "CAPTURE" {
            updateTitle("Capturing Order with ID:\(result.orderID)...")
            captureOrderOnMerchantServer(result: result)
        } else if intent == "AUTHORIZE" {
            updateTitle("Authorizing Order with ID:\(result.orderID)...")
            authorizeOrderOnMerchantServer(result: result)
        }
    }
    
    private func captureOrderOnMerchantServer(result: CardResult) {
        Task {
            let captureResult = try? await DemoMerchantAPI.sharedService.captureOrder(
                orderID: result.orderID, selectedMerchantIntegration: selectedMerchantIntegration
            )
            displayResult(result, orderResult: captureResult)
        }
    }
    
    private func authorizeOrderOnMerchantServer(result: CardResult) {
        Task {
            let authorizeResult = try? await DemoMerchantAPI.sharedService.authorizeOrder(
                orderID: result.orderID, selectedMerchantIntegration: selectedMerchantIntegration
            )
            displayResult(result, orderResult: authorizeResult)
        }
    }
    
    private func displayResult(_ cardResult: CardResult, orderResult: Order?) {
        let status = orderResult?.status ?? ""
        let vault = orderResult?.paymentSource?.card.attributes?.vault
        let orderInfo = "Order ID: \(cardResult.orderID) \n Status: \(status)"
        let vaultInfo = vault != nil ? "Vault Status: \((vault?.status) ?? "") \n Vault ID: \((vault?.id) ?? "")" : ""
        let customerInfo = vault != nil ? "Customer ID: \((vault?.customer.id ?? ""))" : ""
                
        updateTitle("\(orderInfo) \n \(vaultInfo)\n \(customerInfo)")
    }
    
    func card(_ cardClient: CardClient, didFinishWithError error: CoreSDKError) {
        updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
        print("❌ There was an error: \(error)")
    }

    func cardDidCancel(_ cardClient: CardClient) {
        updateTitle("\(DemoSettings.intent) cancelled")
        print("❌ Buyer has cancelled the Card flow")
    }

    func cardThreeDSecureWillLaunch(_ cardClient: CardClient) {
        updateTitle("3DS challenge will be launched")
        print("3DS challenge will be launched")
    }

    func cardThreeDSecureDidFinish(_ cardClient: CardClient) {
        updateTitle("3DS challenge has finished")
        print("3DS challenge has finished")
    }

    func getClientID() async -> String? {
        await DemoMerchantAPI.sharedService.getClientID(
            environment: DemoSettings.environment, selectedMerchantIntegration: selectedMerchantIntegration
        )
    }
    
    func getCoreConfig() async -> CoreConfig? {
        guard let clientID = await getClientID() else {
            return nil
        }
        return CoreConfig(clientID: clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
    }

    func getNativeCheckoutClient() async throws -> PayPalNativeCheckoutClient {
        guard let config = await getCoreConfig() else {
            throw CoreSDKError(code: 0, domain: "Error initializing paypal webcheckout client", errorDescription: nil)
        }
        return PayPalNativeCheckoutClient(config: config)
    }

    func getPayPalClient() async throws -> PayPalWebCheckoutClient {
        guard let config = await getCoreConfig() else {
            throw CoreSDKError(code: 0, domain: "Error initializing paypal webcheckout client", errorDescription: nil)
        }
        let payPalClient = PayPalWebCheckoutClient(config: config)
        return payPalClient
    }
}
