# CLAUDE.md

PayPal's iOS SDK. One merchant integration for card and PayPal checkout. Minimum iOS 16, Swift 5.9.

## Layout

* `Sources/CorePayments` — `CoreConfig`, sandbox and live hosts, REST and GraphQL networking.
* `Sources/CardPayments` — card approval and vaulting. Merchants build the card fields.
* `Sources/PayPalPayments` — PayPal checkout and vault.
* `Sources/PaymentButtons` — PayPal button UI and keyboard inset reset for a payment form scroll view.
* `Sources/FraudProtection` — device data collected through PPRiskMagnes.
* `UnitTests` — XCTest suites, run from the `UnitTests` scheme.
* `Demo` — sample app. Defaults to the PayPal sandbox.

`CoreConfig.environment` is `.sandbox` or `.live`. Sandbox GraphQL is `https://www.sandbox.paypal.com/graphql`. Live GraphQL is `https://www.paypal.com/graphql`. Do not hardcode credentials, private keys, or payment tokens.

## Keyboard on a payment form

`PayPalNativePayments` used to present the native paysheet. That module was removed in 2.0.0. Card entry is the merchant's form.

`.clearsKeyboardScrollSpace()` keeps one bottom inset while the keyboard is visible: keyboard overlap minus the safe area. When the keyboard hides, that inset is `0` on the form scroll view and on any scroll view behind it, and the offset is clamped to the form. That is the blank space and second scroll indicator in issue #246.

Sandbox tests build a `UIScrollView` with a stuck inset and assert it clears. They do not call PayPal.

## Checks

```sh
swiftlint
xcodebuild -workspace PayPal.xcworkspace -scheme UnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PaymentButtonsTests test CODE_SIGNING_ALLOWED=NO
```

The package products are declared in `Package.swift`. CocoaPods subspecs are in `PayPal.podspec`.
