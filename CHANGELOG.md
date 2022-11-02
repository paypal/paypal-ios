
# PayPal iOS SDK Release Notes

## unreleased
* PayPalUI
    * Fix fatal crash with iOS 16: `UIViewRepresentables must be value types`. Separate buttons into `UIKit` and `SwiftUI` implementations.
    
    | UIKit      | SwiftUI |
    | ----------- | ----------- |
    | PayPalButton      | PayPalButton.Representable       |
    | PayPalCreditButton   | PayPalCreditButton.Representable        |
    | PayPalPayLaterButton   | PayPalPayLaterButton.Representable        |
    
* PayPalNativeCheckout
    * Update to version 0.109.0 that fixes shipping callback bug
* Bump minimum supported deployment target to iOS 14+
* Require Xcode 14
    * Bump Swift Tools Version to 5.7 for CocoaPods & SPM

## 0.0.1 (2022-07-21)

* Card
  * Add `Address`
  * Add `Card`
  * Add `CardClient`
  * Add `CardRequest`
  * Add `CardResult`
  
* PayPalCheckout
  * Add `PayPalWebCheckout`
  
* PayPalUI
  * Add `PayPalButton` Button
  * Add `PayPalPayLater` Button
  * Add `PayPalCredit` Button

* PayPalDataCollector
  * Add `PayPalDataCollector`
  * Add `MagnesSDK`
