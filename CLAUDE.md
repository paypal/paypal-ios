# CLAUDE.md

PayPal's iOS SDK. One merchant integration for card and PayPal checkout. Minimum iOS 16, Swift 5.9.

## Layout

* `Sources/CorePayments` — `CoreConfig`, sandbox and live hosts, REST and GraphQL networking.
* `Sources/CardPayments` — card approval against Orders v2.
* `Sources/PayPalPayments` — PayPal checkout and vault.
* `Sources/PaymentButtons` — PayPal button UI.
* `Sources/FraudProtection` — device data collected through PPRiskMagnes.
* `UnitTests` — XCTest suites, run from the `UnitTests` scheme.
* `Demo` — sample app. Defaults to the PayPal sandbox.

`CoreConfig.environment` is `.sandbox` or `.live`. Sandbox GraphQL is `https://www.sandbox.paypal.com/graphql`. Live GraphQL is `https://www.paypal.com/graphql`. Do not hardcode credentials, private keys, or payment tokens.

## Fraud protection

`PayPalDataCollector.collectDeviceData` is the public entry point. Magnes signs the payload with a process-wide private key (`PFBaseSecureKeyWrapper`).

* Read the keychain device id as `Data`. `SecItemCopyMatching` with `kSecReturnData` does not return a dictionary. A failed read minted a new id on every call and made Magnes generate a new signing key.
* Collect on one lock. Overlapping `getSignatureBytesUsingPrivateKey` calls are the crash in issue #272.
* A Magnes failure returns `{"correlation_id":""}`. Checkout continues. The SDK does not catch a native memory fault; it avoids the call pattern that causes one.

Sandbox tests use `CoreConfig.environment == .sandbox` and assert Magnes is configured with `.SANDBOX`. They do not call PayPal with a real card.

## Checks

```sh
swiftlint
xcodebuild -workspace PayPal.xcworkspace -scheme UnitTests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:FraudProtectionTests test CODE_SIGNING_ALLOWED=NO
```

The package products are declared in `Package.swift`. CocoaPods subspecs are in `PayPal.podspec`.
