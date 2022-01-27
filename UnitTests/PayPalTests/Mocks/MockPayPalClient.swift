import UIKit

class MockPayPalClient: PayPalClient {

    var cannedURLString: String?

    override func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> URL? {
        URL(string: cannedURLString ?? "")
    }
}
