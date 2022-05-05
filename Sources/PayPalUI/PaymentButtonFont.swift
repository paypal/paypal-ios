//
//  PaymentButtonFont.swift
//  PayPalUI
//
//  Created by Jose Noriega on 02/05/2022.
//

import UIKit

//TODO: check ContentConfig class in NXO
class PaymentButtonFont {
    /// The primary font to be employed in the UI for non special circumstances
    public static let primaryFont: UIFont = .systemFont(ofSize: UIFont.systemFontSize)

    /// Usually a sub-heading or alternative text font that is used in some scenarios
    public static let secondaryFont: UIFont = .systemFont(ofSize: UIFont.smallSystemFontSize)

    /// A sub-sub heading in most cases. Smaller than secondary font in size
    public static let tertiaryFont: UIFont = .systemFont(ofSize: UIFont.smallSystemFontSize - 3)
}
