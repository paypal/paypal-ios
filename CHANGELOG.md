
# PayPal iOS SDK Release Notes

## unreleased
* Bump to PPRiskMagnes v5.5.0 with code signing & a privacy manifest file
* Require Xcode 15.0+ and Swift 5.9+ (per [App Store requirements](https://developer.apple.com/news/?id=khzvxn8a))
* [Meets Apple's new Privacy Update requirements](https://developer.apple.com/news/?id=3d8a9yyh)
* PaymentButtons
  * Add `custom` case for `PaymentButtonEdges`
  * Support VoiceOver by adding button accessibility labels
  * Fixed frame alignment and width issue occuring in SwiftUI
  * Fixed button alignment and size bug in SwiftUI with `intrinsicContentSize`
    * The height cannot be set smaller than 38px or width shorter than 300px
  * Added analytics events
    * `payment-button:initialized` and `payment-button:tapped`
* CardPayments
  * Add `status` property to `CardVaultResult`
  * Add `didAttemptThreeDSecureAuthentication` property to `CardVaultResult`
  * Add `status` property to `CardResult`
  * Add `didAttemptThreeDSecureAuthentication` property to `CardResult`
  * Add `cardThreeDSecureDidCancel()` to `CardVaultDelegate`
  * Add `cardThreeDSecureWillLaunch()` to `CardVaultDelegate`
  * Add `cardThreeDSecureDidFinish()` to `CardVaultDelegate`
* PayPalWebPayments  
  * Add `PayPalVaultRequest` type for interacting with `vault` method
  * Add `vault(_:)` method to `PayPalWebCheckoutClient`
  * Add `PayPalVaultResult` type to return vault result
  * Add `PayPalVaultDelegate` to handle results from vault flow
  * Add `PayPalWebCheckoutClientError.paypalVaultResponseError` for missing or invalid response from vaulting

## 1.1.0 (2023-11-16)
* PayPalNativePayments
  * Bump `PayPalCheckout` to `1.2.0`
  * Update `PayPalNativeCheckoutRequest` initalizer to accept optional param `userAuthenticationEmail`
* CorePayments
  * Analytics
    * Update `component` from `ppcpmobilesdk` to `ppcpclientsdk`
    * Send `correlation_id`, when possible, in PayPal Native Checkout analytic events

## 1.0.0 (2023-10-02)
* Breaking Changes
  * Require Xcode 14.3+ and Swift 5.8+
* Update Package.swift to include `PayPalCheckout` via a binary target. This works around an SPM bug that included `PayPalCheckout` even for integrations that did not include the `PayPalNativePayments` module.

## 0.0.11 (2023-08-22)
* PayPalNativePayments
  * Bump `PayPalCheckout` to `1.1.0`
* CardPayments
  * Add `vault` method 
  * Add `CardVaultRequest` and `CardVaultResult` types for interacting with `vault` method
  * Add `CardVaultDelegate` protocol to receive success and failure results
  * Add `CardVaultDelegate` property to `CardClient`
* Breaking Changes
  * FraudProtection
    * Update `PayPalDataCollector` constructor to require a configuration instead of an environment
    * Remove `PayPalDataCollectorEnvironment` enum

## 0.0.10 (2023-08-14)
* PayPalNativePayments
  * Bump `PayPalCheckout` to `1.0.0`
* PaymentsCore
  * Allow `ASWebAuthenticationSession` used for PayPal Web & 3DS flows to share cookies with Safari (fixes #179)
  
## 0.0.9 (2023-06-23)
* Breaking Changes
  * CardPayments
    * Remove `status` property from `CardResult`
    * Remove `paymentSource` property from `CardResult`
  * CorePayments
    * CoreConfig instances must now be instantiated using a `clientID` instead of an `accessToken`

## 0.0.8 (2023-05-08)
* PayPalNativePayments
  * Add `PayPalNativePaysheetActions` to `PayPalNativeShippingDelegate.didShippingAddressChange()` and `PayPalNativeShippingDelegate.didShippingMethodChange()`
* Card
  * Rename `Card.init()` parameter from `cardHolderName` to `cardholderName`
  * Remove unnecessary `Card.expiry` property
* CorePayments
  * Send `orderID` instead of `sessionID` for analytics

## 0.0.7 (2023-03-28)
* PayPalNativePayments
  * Update `PayPalNativeCheckoutDelegate.paypal(_:didFinishWithResult:)` to use `PayPalNativeCheckoutResult` instead of `PayPalCheckout.Approval` type.
  * Update `PayPalNativeCheckoutClient.start(presentingViewController:createOrder)` to `PayPalNativeCheckoutClient.start(request:presentingViewController:)`
    * Require `PayPalNativeCheckoutRequest` param instead of `PayPalCheckout.CheckoutConfig.CreateOrderCallback`
  * Add `PayPalNativeShippingDelegate` as optional delegate on `PayPalNativeCheckoutClient`
    * Add `PayPalNativeShippingDelegate.didShippingAddressChange()`
    * Add `PayPalNativeShippingDelegate.didShippingMethodChange()`
    * Remove `PayPalNativeCheckoutDelegate.paypalDidShippingAddressChange()`
  * Update `PayPalNativeCheckoutDelegate.paypal(_:didFinishWithResult:)` to use `PayPalNativeCheckoutResult` instead of `PayPalCheckout.Approval` type.

## 0.0.6 (2023-02-21)
* Fix CocoaPods build error for Xcode 13

## 0.0.5 (2023-02-21)
* Rename `PaymentsCore` to `CorePayments`
* Rename `PayPalDataCollector` to `FraudProtection`
* Rename `PayPalNativeCheckout` to `PayPalNativePayments`
* Rename `PayPalWebCheckout` to `PayPalWebPayments`
* Rename `PayPalUI` to `PaymentButtons`
* Rename `Card` to `CardPayments`
* PayPalUI
    * Fix issue where label was not being shown
* Rename `Environment.production` enum case to `Environment.live`
* Send analytic events for `PayPalNativePayments`, `PayPalWebPayments`, and `CardPayments` flows

## 0.0.4 (2023-01-17)
* Card
  * Remove `ThreeDSecureRequest` from `CardRequest` and create URLs internally 
  * Update `CardRequest` to optionally pass `sca`
  * Remove step requiring `ASWebAuthenticationPresentationContextProviding` conformance
* PayPalWebCheckout
  * Remove step requiring `ASWebAuthenticationPresentationContextProviding` conformance
* PayPalUI
  * Fix assets not rendering when importing with Swift Package Manager and CocoaPods

## 0.0.3 (2022-11-03)
* PayPalNativeCheckout
    * Expose PayPalNativeCheckout through Swift Package Manager

## 0.0.2 (2022-11-03)
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
