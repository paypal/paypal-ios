import UIKit
import PayPal
import PaymentsCore

// TODO: revert all of this before putting up PR and create story for adding this in/using process order

class PayPalDemoViewController: FeatureBaseViewController, PayPalInterfaceDelegate {

    func paypal(_ paypal: PayPalInterface, didApproveWith data: PayPalResult) {
        print("Authorize something")
    }

    func paypal(_ paypal: PayPalInterface, didReceiveError error: PayPalSDKError) {
        print("ERROR!!!! :(")
    }

    func paypalDidCancel(_ paypal: PayPalInterface) {
        print("Canceled")
    }


    var config: CoreConfig {
        CoreConfig(
            clientID: "ASUApeBhpz9-IhrBRpHbBfVBklK4XOr1lvZdgu1UlSK0OvoJut6R-zPUP7iufxso55Yvyl6IZYV3yr0g",
            environment: .sandbox,
            returnUrl: "northstar://paypalpay"
        )
    }

    lazy var payPalInterface: PayPalInterface = {
        try! PayPalInterface(config: config)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        payPalInterface.delegate = self

        view.backgroundColor = .blue
    }

    override func createOrder(completion: @escaping (String?) -> Void = { _ in }) {
        super.createOrder { orderID in
            if orderID != nil {
                self.payPalInterface.startPayPalCheckout(presentingViewController: self, orderID: orderID!)
            } else {
                print("Aaaaaa there was an error")
            }
        }
    }
}
