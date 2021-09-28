import UIKit
import Card
import PayPal

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // TODO: Update Demo UI with proper Card & PayPal checkout demos
        fetchOrderID()
    }

    func fetchOrderID() {
        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            intent: "CAPTURE",
            purchaseUnits: [PurchaseUnit(amount: amount)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            switch result {
            case .success(let order):
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }
}
