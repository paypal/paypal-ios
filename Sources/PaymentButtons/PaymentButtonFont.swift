import UIKit

enum PaymentButtonFont {
    /// The primary font used for non special circumstances
    public static let paypalPrimaryFont = UIFont(name: "PayPalOpen-Regular", size: 14) ??
        .systemFont(ofSize: UIFont.systemFontSize)

    /// The secondary font for sub-heading or alternative text
    public static let paypalSecondaryFont = UIFont(name: "PayPalOpen-Regular", size: 12) ??
        .systemFont(ofSize: UIFont.smallSystemFontSize)

    /// Large font of size 18
    public static let paypalSize18Font = UIFont(name: "PayPalOpen-Regular", size: 18) ??
        .systemFont(ofSize: UIFont.systemFontSize + 4)
}
