import UIKit
import Card
import PayPal

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        fetchOrderID()
    }
    
    func fetchOrderID() {
        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(intent: "CAPTURE",
                                                   purchaseUnits: [PurchaseUnit(amount: amount)])
        
        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { order, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let order = order else {
                return
            }
            
            print("Get orderID: \(order)")
        }
    }
    
}
