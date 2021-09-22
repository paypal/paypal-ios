import UIKit

class FeatureBaseViewController: UIViewController {
    
    let bottomToolbar = UIToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBottomToolbar()
        fetchOrderID()
    }
    
    func configureBottomToolbar() {
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomToolbar)
        
        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func fetchOrderID() {
        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
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
    
    func processOrder() {
        // TODO: - Update progress bar/ toolbar to show status of demo (order fetched, processing, etc)
    }
    
}
