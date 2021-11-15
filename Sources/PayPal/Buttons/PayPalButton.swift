import UIKit

public class PayPalButton: UIButton {

    // delegate to hook into the button
    public weak var delegate: PaymentButtonDelegate?
    
    // asset identfier path for image and color button assets
    private let bundleIdentifier = Bundle(identifier: "com.paypal.ios-sdk.PayPal")
    
    // MARK: - Init

    public init() {
        super.init(frame: .zero)
        
        let payPalGold = UIColor(named: "PayPalGold", in: bundleIdentifier, compatibleWith: nil)
        let payPalLogo = UIImage(named: "PayPalLogo", in: bundleIdentifier, compatibleWith: nil)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = payPalGold
        layer.cornerRadius = 4.0
        setImage(payPalLogo, for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
 
    // MARK: - Deinit

    deinit { }
}
