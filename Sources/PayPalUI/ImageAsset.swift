//
//  ImageAsset.swift
//  PayPalUI
//
//  Created by Jose Noriega on 04/05/2022.
//

import UIKit

final class ImageAsset {
    static func paymentButtonLogo(for button: PaymentButton) -> UIImage? {
      var imageAssetString = ""
      switch button.fundingSource {
      case .payPal:
        imageAssetString += "paypal_"

        if button.size == .mini {
          imageAssetString += "monogram_"
        }

      case .payLater:
        imageAssetString += "paypal_monogram_"

      case .credit:
        imageAssetString += "credit_"
      }

      switch button.color {
      case .gold, .white, .silver:
        imageAssetString += "color"

      case .black, .darkBlue:
        imageAssetString += "monochrome"

      case .blue:
        imageAssetString += "blue"
      }

//      guard let logoImage = ImageAsset(rawValue: imageAssetString) else {
//        return nil
//      }
        
      return UIImage(named: imageAssetString, in: PaymentButton.bundle, compatibleWith: nil)
    }
}
