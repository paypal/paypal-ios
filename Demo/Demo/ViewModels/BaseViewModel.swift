import UIKit
import Card
import PayPalWebCheckout
import PaymentsCore
import AuthenticationServices

/// This class is used to share the orderID across shared views, update the text of `bottomStatusLabel` in our `FeatureBaseViewController`
/// as well as share the logic of `processOrder` across our duplicate (SwiftUI and UIKit) card views.
class BaseViewModel: ObservableObject, PayPalWebDelegate {

    /// Weak reference to associated view
    weak var view: FeatureBaseViewController?

    /// order ID shared across views
    @Published var orderID: String?

    lazy var payPalClient: PayPalWebCheckoutClient = {
        let clientID = DemoSettings.clientID
        let environment = DemoSettings.environment.paypalSDKEnvironment
        let config = CoreConfig(clientID: clientID, environment: environment)
        let payPalClient = PayPalWebCheckoutClient(config: config)
        return payPalClient
    }()

    // MARK: - Init

    init(view: FeatureBaseViewController? = nil) {
        self.view = view
        payPalClient.delegate = self
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

    func checkoutWithCard(_ card: Card, orderID: String) async {
        let config = CoreConfig(clientID: DemoSettings.clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
        let cardClient = CardClient(config: config)
        let cardRequest = CardRequest(orderID: orderID, card: card)

        do {
            _ = try await cardClient.approveOrder(request: cardRequest)
            updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: CONFIRMED")
        } catch {
            updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
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

    func payPalButtonTapped(context: ASWebAuthenticationPresentationContextProviding) {
        guard let orderID = orderID else {
            self.updateTitle("Failed: missing orderID.")
            return
        }

        checkoutWithPayPal(orderID: orderID, context: context)
    }

    func checkoutWithPayPal(orderID: String, context: ASWebAuthenticationPresentationContextProviding) {
        let payPalRequest = PayPalWebRequest(orderID: orderID)
        payPalClient.start(request: payPalRequest, context: context)
    }

    // MARK: - PayPal Delegate

    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebResult) {
        updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: CONFIRMED")
        print("✅ Order is successfully approved and ready to be captured/authorized with result: \(result)")
    }

    func paypal(_ paypalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
        print("❌ There was an error: \(error)")
    }

    func paypalDidCancel(_ paypalClient: PayPalWebCheckoutClient) {
        updateTitle("\(DemoSettings.intent) cancelled")
        print("❌ Buyer has cancelled the PayPal flow")
    }
}
