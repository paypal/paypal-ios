import UIKit
import Card
import PaymentsCore

/// This class is used to share the orderID across shared views, update the text of `bottomStatusLabel` in our `FeatureBaseViewController`
/// as well as share the logic of `processOrder` across our duplicate (SwiftUI and UIKit) card views.
class BaseViewModel: ObservableObject {

    /// Weak reference to associated view
    weak var view: FeatureBaseViewController?

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

    func createOrder(amount: String?, completion: @escaping (String?) -> Void = { _ in }) {
        updateTitle("Creating order...")

        guard let amount = amount else { return }

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            switch result {
            case .success(let order):
                self.updateTitle("Order ID: \(order.id)")
                self.updateOrderID(with: order.id)
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                self.updateTitle("Your order has failed, please try again")
                print("❌ failed to fetch orderID: \(error)")
            }
            DispatchQueue.main.async {
                completion(self.orderID)
            }
        }
    }

    func processOrder(orderID: String, completion: @escaping () -> Void = {}) {
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

        DemoMerchantAPI.sharedService.processOrder(processOrderParams: processOrderParams) { result in
            switch result {
            case .success(let order):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) success: \(order.status)")
                print("✅ processed orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) fail: \(error.localizedDescription)")
                print("❌ failed to process orderID: \(error)")
            }
            completion()
        }
    }

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

    func checkoutWithCard(_ card: Card, orderID: String, completion: @escaping () -> Void = { }) {
        let config = CoreConfig(clientID: DemoSettings.clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
        let cardClient = CardClient(config: config)
        let cardRequest = CardRequest(orderID: orderID, card: card)

        cardClient.approveOrder(request: cardRequest) { result in
            switch result {
            case .success(let result):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: APPROVED")
                self.processOrder(orderID: result.orderID) {
                    completion()
                }
            case .failure(let error):
                self.updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
            }
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
}
