import UIKit

enum PaymentButtonFont {
    /// The primary font to be employed in the UI for non special circumstances
    public static let primaryFont: UIFont = .systemFont(ofSize: UIFont.systemFontSize)

    /// Usually a sub-heading or alternative text font that is used in some scenarios
    public static let secondaryFont: UIFont = .systemFont(ofSize: UIFont.smallSystemFontSize)

    /// Large font of size 18
    public static let systemFont18: UIFont = .systemFont(ofSize: UIFont.systemFontSize + 4)
}
