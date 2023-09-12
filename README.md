# PayPal iOS SDK

Welcome to PayPal's iOS SDK. This library will help you accept card, PayPal, Venmo, and alternative payment methods in your iOS app.

## FAQ
### Availability
The SDK is currently in the development process. This product is being developed fully open source - throughout the development process, we welcome any and all feedback. Aspects of the SDK _will likely_ change as we develop the SDK. We recommend using the SDK in the sandbox environment until an official release is available. This README will be updated with an official release date once it is generally available.

### Contribution
As the SDK is moved to general availability, we will be adding a contribution guide for developers that would like to contribute to the SDK. If you have suggestions for features that you would like to see in future iterations of the SDK, please feel free to open an issue, PR, or discussion with suggestions. If you want to open a PR but are unsure about our testing strategy, we are more than happy to work with you to add tests to any PRs before work is merged.

## Support

The PayPal iOS SDK supports a minimum deployment target of iOS 14+ and requires Xcode 14.3+ and macOS Monterey 13. See our [Client Deprecation policy](https://developer.paypal.com/braintree/docs/guides/client-sdk/deprecation-policy/ios/v5) to plan for updates.

### Package Managers
This SDK supports:

* CocoaPods
* Swift Package Manager

### Languages

This SDK supports Swift 5.7+. This SDK is written in Swift.

### UI Frameworks
This SDK supports:

* UIKit
* SwiftUI

## Client ID

The PayPal SDK uses a client ID for authentication. This can be found in your [PayPal Developer Dashboard](https://developer.paypal.com/api/rest/#link-getstarted).

## Modules

Each feature module has its own onboarding guide:

- [CardPayments](docs/CardPayments)
- [PaymentButtons](docs/PaymentButtons)
- [PayPal Native Payments](docs/PayPalNativePayments)
- [PayPal Web Payments](docs/PayPalWebPayments)

To accept a certain payment method in your app, you only need to include that payment-specific submodule.

## Demo

1. Open `PayPal.xcworkspace` in Xcode
2. Resolve the Swift Package Manager packages if needed: `File` > `Packages` > `Resolve Package Versions` or by running `swift package resolve` in Terminal
3. Select the `Demo` scheme, and then run

Xcode 14.3+ is required to run the demo app.

## Testing

This project uses the `XCTest` framework provided by Xcode. Every code path should be unit tested. Unit tests should make up most of the test coverage, with integration, and then UI tests following.

This project also takes advantage of `Fastlane` to run tests through our CI and from terminal.
In order to invoke our unit tests through terminal, run the following commands from the root level directory of the repository:
```
bundle install
bundle exec fastlane unit_tests
```

If you would like to get the code coverage for all of the modules within the workspace, run the following:
```
bundle install
bundle exec fastlane coverage
```

### CI

GitHub Actions CI will run all tests and build commands per package manager on each PR.

### Local Testing

TBD until development progresses. We will use Rake, Fastlane, or some other tool for easy command-line build tasks.

## Release Process

This SDK follows [Semantic Versioning](https://semver.org/). The release process will be automated via GitHub Actions.

## Analytics

Client analytics will be collected via Lighthouse/FPTI.
