# CLAUDE.md

PayPal's iOS SDK. One merchant integration for card and PayPal checkout. Minimum iOS 16, Swift 5.9.

## Layout

* `Sources/CorePayments` — `CoreConfig`, sandbox and live hosts, REST and GraphQL networking.
* `Sources/CardPayments` — card approval and vaulting.
* `Sources/PayPalPayments` — PayPal checkout, vault, and Venmo.
* `Sources/PaymentButtons` — PayPal button UI.
* `Sources/FraudProtection` — device data collected through PPRiskMagnes.
* `UnitTests` — XCTest suites, run from the `UnitTests` scheme.
* `Demo` — sample app. Defaults to the PayPal sandbox.

`CoreConfig.environment` is `.sandbox` or `.live`. Sandbox GraphQL is `https://www.sandbox.paypal.com/graphql`. Live GraphQL is `https://www.paypal.com/graphql`. Do not hardcode credentials, private keys, or payment tokens.

## Venmo

`PayPalClient.start(orderID:fundingSource: .venmo)` approves an order the server already created. The checkout page is `/smart/checkout/venmo/popup` on `www.sandbox.paypal.com` or `www.paypal.com`.

* The Venmo app opens when `canOpenURL("venmo://")` is true. The host app must list `venmo` in `LSApplicationQueriesSchemes`.
* Otherwise the same page loads in `ASWebAuthenticationSession`.
* `updateClientConfig` is called with funding source `venmo`. Capture stays on the server.

Sandbox tests use a fake client id and assert the sandbox host. They do not call PayPal with a real buyer.

## Checks

```sh
swiftlint
xcodebuild -workspace PayPal.xcworkspace -scheme UnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PayPalPaymentsTests test CODE_SIGNING_ALLOWED=NO
```

The package products are declared in `Package.swift`. CocoaPods subspecs are in `PayPal.podspec`.
