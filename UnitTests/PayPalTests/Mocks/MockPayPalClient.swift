import UIKit

class MockPayPalClient: PayPalClient {

    override func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> URL? {
        URL(string: "")
    }
}
