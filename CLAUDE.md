# CLAUDE.md

PayPal's iOS SDK. One merchant integration for card, PayPal checkout, and Apple Pay. Minimum iOS 16, Swift 5.9.

## Layout

* `Sources/CorePayments` — `CoreConfig`, sandbox and live hosts, REST and GraphQL networking.
* `Sources/CardPayments` — card approval against Orders v2.
* `Sources/PayPalPayments` — PayPal checkout and vault.
* `Sources/PaymentButtons` — PayPal button UI.
* `Sources/FraudProtection` — device data.
* `Sources/ApplePay` — native Apple Pay for an existing PayPal order.
* `UnitTests` — XCTest suites, run from the `UnitTests` scheme.
* `Demo` — sample app. Defaults to the PayPal sandbox.

`CoreConfig.environment` is `.sandbox` or `.live`. Sandbox GraphQL is `https://www.sandbox.paypal.com/graphql`. Live GraphQL is `https://www.paypal.com/graphql`. Do not hardcode credentials, private keys, or payment tokens.

## Apple Pay

`ApplePayClient.approveOrder` is the public entry point.

1. The merchant server creates an order and returns only the order ID.
2. `ApplePayAPI` loads eligibility, country, networks, and capabilities with `GetApplepayConfig`.
3. `ApplePayPaymentRequestBuilder` turns that config into a `PKPaymentRequest`. The app supplies its Apple merchant ID.
4. `PassKitApplePayAuthorizer` presents `PKPaymentAuthorizationController`.
5. On authorize, the payment token is forwarded unchanged and confirmed with `ApproveApplePayPayment` before the sheet reports success.
6. The app captures or authorizes the order on the server.

This is the same confirm operation the web JS SDK uses (`paypal.Applepay().confirmOrder`). PassKit performs merchant validation, so the web `validateMerchant` call is not used. The buyer stays in the app. A Braintree account is not required.

`ApplePayAuthorizing` and `ApplePayServicing` are the seams unit tests replace. Tests that mention sandbox assert the sandbox host and the GraphQL operation names. They do not call PayPal or Apple with a real card.

## Checks

```sh
swiftlint
xcodebuild -workspace PayPal.xcworkspace -scheme UnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:ApplePayTests test CODE_SIGNING_ALLOWED=NO
```

The package products are declared in `Package.swift`. CocoaPods subspecs are in `PayPal.podspec`.
