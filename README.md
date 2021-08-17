# PayPal iOS SDK

Welcome to PayPal's iOS SDK. This library will help you accept card, PayPal, Venmo, and alternative payment methods in your iOS app.

## Support

The PayPal iOS SDK supports a minimum deployment target of iOS 13+ and requires Xcode 13+ and macOS Big Sur 11.3+. See our [Client Deprecation policy](https://developer.paypal.com/braintree/docs/guides/client-sdk/deprecation-policy/ios/v5) to plan for updates.

### Package Managers
This SDK supports:

* CocoaPods
* Swift Package Manager

### Languages

This SDK supports Swift 5.1+. This SDK is written in Swift.

### UI Frameworks
This SDK supports:

* UIKit
* SwiftUI

## Modularity

The PayPal iOS SDK is comprised of various submodules.
* `Card`
* `PayPal`
* ...

To accept a certain payment method in your app, you only need to include that payment-specific submodule.

## Sample Code

```
// STEP 0: Fetch an ACCESS_TOKEN and ORDER_ID from your server.

// STEP 1: Create a PaymentConfiguration object
paymentConfig = PaymentConfig(token: ACCESS_TOKEN)

// STEP 2: Create payment method client objects
cardClient = CardClient(config: paymentConfig)

// STEP 3: Collect relevant payment method details
card = Card(number: 4111111111111111, cvv: 123, ...)

// STEP 4: Call checkout method
cardClient?.checkoutWithCard(orderID: ORDER_ID, card: card) { result in
    switch result {
    case .success(let orderId):
      // Send orderID to your server to process the payment
    case .error(let error):
      // handle checkout error
    }
}

// STEP 5: Send orderID to your server to capture/authorize

```

## Prerequisites

### SwiftLint

If you would like to run SwiftLint outside of CI for all of the modules within the `iOS-SDK`, run the following:

```
bundle install
bundle exec fastlane lint
```

## Testing

This project uses the `XCTest` framework provided by Xcode. Every code path should be unit tested. Unit tests should make up most of the test coverage, with integration, and then UI tests following.

This project also takes advantage of `Fastlane` to run tests through our CI and from terminal.
In order to invoke our unit tests through terminal, run the following commands from the root level directory of the repository:
```
bundle install
bundle exec fastlane unit_tests
```

### CI

GitHub Actions CI will run all tests and build commands per package manager on each PR.

### Local Testing

TBD until development progresses. We will use Rake, Fastlane, or some other tool for easy command-line build tasks.

## Release Process

This SDK follows [Semantic Versioning](https://semver.org/). The release process will be automated via GitHub Actions.

## Analytics

Client analytics will be collected via Lighthouse/FPTI.
