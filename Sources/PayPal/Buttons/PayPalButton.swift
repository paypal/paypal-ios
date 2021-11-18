import UIKit

/// Configuration for PayPal button
public class PayPalButton: PaymentButton {

    public init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = getButtonColor(for: .payPal)
        setImage(getButtonLogo(for: .payPal), for: .normal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
