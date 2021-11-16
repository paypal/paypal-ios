import UIKit

public class PayPalCreditButton: UIButton {

    // delegate to hook into the button
    public weak var delegate: PaymentButtonDelegate?
    
    private let paymentButtons = PaymentButtons()
        
    // MARK: - Init

    public init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = paymentButtons.getButtonColor(for: .payPalCredit)
        setImage(paymentButtons.getButtonLogo(for: .payPalCredit), for: .normal)
        layer.cornerRadius = 4.0
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
 
    // MARK: - Deinit

    deinit { }
}
