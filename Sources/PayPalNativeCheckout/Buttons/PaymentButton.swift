import UIKit

/// Handles functionality shared across payment buttons
public class PaymentButton: UIButton {

    // asset identfier path for image and color button assets
    static var bundle = Bundle(identifier: "com.paypal.ios-sdk.PayPal")

    // MARK: - Init

    init(color: PaymentButtonColor, image: PaymentButtonImage) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = color.rawValue
        setImage(image.rawValue, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Function

    /// Once we layout our subviews, we need to update the logo with the button frame
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = getLogoImageInsets()
    }

    // MARK: - Internal Helper Functions

    private func getLogoImageInsets() -> UIEdgeInsets {
        let buttonSize = frame.size
        let insetScaleRatio: CGFloat = 4.0
        return UIEdgeInsets(
            top: buttonSize.height / insetScaleRatio,
            left: buttonSize.width / insetScaleRatio,
            bottom: buttonSize.height / insetScaleRatio,
            right: buttonSize.width / insetScaleRatio
        )
    }
}
