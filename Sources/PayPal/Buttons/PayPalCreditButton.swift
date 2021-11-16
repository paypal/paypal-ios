import UIKit

public class PayPalCreditButton: PaymentButton {

    // MARK: - Init

    public init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = getButtonColor(for: .payPalCredit)
        setImage(getButtonLogo(for: .payPalCredit), for: .normal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinit

    deinit { }
}
