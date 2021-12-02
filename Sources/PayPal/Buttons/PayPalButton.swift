import UIKit

/// Configuration for PayPal button
public class PayPalButton: PaymentButton {

    public init() {
        super.init(color: .gold, image: .payPal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
