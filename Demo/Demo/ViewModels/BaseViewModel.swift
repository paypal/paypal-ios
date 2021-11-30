import UIKit

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
}
