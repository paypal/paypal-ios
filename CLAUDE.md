# CLAUDE.md

PayPal's iOS SDK. One merchant integration for card and PayPal checkout. Minimum iOS 16, Swift 5.9.

## Layout

* `Sources/CorePayments` — `CoreConfig`, sandbox and live hosts, REST and GraphQL networking.
* `Sources/CardPayments` — card approval and vaulting against Orders v2 and `updateVaultSetupToken`.
* `Sources/PayPalPayments` — PayPal checkout and vault.
* `Sources/PaymentButtons` — PayPal button UI.
* `Sources/FraudProtection` — device data collected through PPRiskMagnes.
* `UnitTests` — XCTest suites, run from the `UnitTests` scheme.
* `Demo` — sample app. Defaults to the PayPal sandbox.

`CoreConfig.environment` is `.sandbox` or `.live`. Sandbox GraphQL is `https://www.sandbox.paypal.com/graphql`. Live GraphQL is `https://www.paypal.com/graphql`. Do not hardcode credentials, private keys, or payment tokens.

## Card vaulting

`CardClient.vault` sends `UpdateVaultSetupToken`. `clientID` and `vaultSetupToken` are top-level GraphQL variables. The card lives under `paymentSource.card`.

`Card.billingAddress` is encoded as `paymentSource.card.billingAddress` with `addressLine1`, `addressLine2`, `adminArea1`, `adminArea2`, `postalCode`, and `countryCode`. Omit the object when the card has no billing address. GraphQL encoding does not convert keys to snake case.

Sandbox tests use a fake client id and `CoreConfig.environment == .sandbox`. They do not call PayPal with a real card.

## Checks

```sh
swiftlint
xcodebuild -workspace PayPal.xcworkspace -scheme UnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:CardPaymentsTests test CODE_SIGNING_ALLOWED=NO
```

The package products are declared in `Package.swift`. CocoaPods subspecs are in `PayPal.podspec`.
