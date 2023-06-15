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

    func createOrder(amount: String?) async -> String? {
        updateTitle("Creating order...")
        guard let amount = amount else { return nil }

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
        )

        do {
            let order = try await DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams)
            updateTitle("Order ID: \(order.id)")
            updateOrderID(with: order.id)
            print("✅ fetched orderID: \(order.id) with status: \(order.status)")
        } catch {
            updateTitle("Your order has failed, please try again")
            print("❌ failed to fetch orderID: \(error)")
        }
        return orderID
    }

    func processOrder(orderID: String) async {
        switch DemoSettings.intent {
        case .authorize:
            updateTitle("Authorizing order...")
        case .capture:
            updateTitle("Capturing order...")
        }

        let processOrderParams = ProcessOrderParams(
            orderId: orderID,
            intent: DemoSettings.intent.rawValue,
            countryCode: "US"
        )

        do {
            let order = try await DemoMerchantAPI.sharedService.processOrder(processOrderParams: processOrderParams)
            updateTitle("\(DemoSettings.intent.rawValue.capitalized) success: \(order.status)")
            print("✅ processed orderID: \(order.id) with status: \(order.status)")
        } catch {
            updateTitle("\(DemoSettings.intent.rawValue.capitalized) fail: \(error.localizedDescription)")
            print("❌ failed to process orderID: \(error)")
        }
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

    func checkoutWith(
        card: Card,
        orderID: String,
        shouldVault: Bool = false,
        customerID: String = ""
    ) async {
        guard let config = await getCoreConfig() else {
            return
        }
        let cardClient = CardClient(config: config)
        cardClient.delegate = self
        
        var passedCustomerID: String?
        if customerID.isEmpty {
            passedCustomerID = nil
        } else {
            passedCustomerID = customerID
        }
        let cardRequest = CardRequest(orderID: orderID, card: card, sca: .scaAlways, shouldVault: shouldVault, customerID: passedCustomerID)
        cardClient.approveOrder(request: cardRequest)
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
            let captureResult = try? await DemoMerchantAPI.sharedService.caputureOrder(orderID: result.orderID)
            let status = captureResult?.status ?? ""
            updateTitle("Order ID:\(result.orderID) status: \(status)")
        }
    }
    
    private func authorizeOrderOnMerchantServer(result: CardResult) {
        Task {
            let authorizeResult = try? await DemoMerchantAPI.sharedService.authorizeOrder(orderID: result.orderID)
            let status = authorizeResult?.status ?? ""
            updateTitle("Order ID:\(result.orderID) status: \(status)")
        }
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
        await DemoMerchantAPI.sharedService.getClientID(environment: DemoSettings.environment)
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
