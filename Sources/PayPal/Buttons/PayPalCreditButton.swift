import UIKit

/// Configuration for PayPal Credit button
public class PayPalCreditButton: PaymentButton {

    public init() {
        super.init(color: .darkBlue, image: .payPalCredit)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
