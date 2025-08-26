# PayPal iOS SDK

Welcome to PayPal's iOS SDK. This library will help you accept card and PayPal payment methods in your iOS app.

## FAQ
### Contribution
If you have suggestions for features that you would like to see in future iterations of the SDK, please feel free to open an issue, PR, or discussion with suggestions. This product is fully open source. We welcome any and all feedback.

## Support

The PayPal iOS SDK supports a minimum deployment target of iOS 14+ and requires Xcode 15.0+ and macOS Ventura 13. See our [Client Deprecation policy](https://developer.paypal.com/braintree/docs/guides/client-sdk/deprecation-policy/ios/v5) to plan for updates.

### Package Managers
This SDK supports:

* CocoaPods
* Swift Package Manager

### Languages

This SDK supports Swift 5.9+. This SDK is written in Swift.

### UI Frameworks
This SDK supports:

* UIKit
* SwiftUI

## Client ID

The PayPal SDK uses a client ID for authentication. This can be found in your [PayPal Developer Dashboard](https://developer.paypal.com/api/rest/#link-getstarted).

## Documentation

Documentation for the PayPal iOS SDK can be found [here](https://developer.paypal.com/docs/checkout/advanced/ios/).

## Demo

1. Open `PayPal.xcworkspace` in Xcode
1. Resolve the Swift Package Manager packages if needed: `File` > `Packages` > `Resolve Package Versions` or by running `swift package resolve` in Terminal
1. Select the `Demo` scheme, and then run

Xcode 14.3+ is required to run the demo app.

## Testing

This project uses the `XCTest` framework provided by Xcode. Every code path should be unit tested. Unit tests should make up most of the test coverage, with integration, and then UI tests following.

### CI

GitHub Actions CI will run all tests and build commands per package manager on each PR.

### Local Testing

Our Xcode project uses [SwiftLint](https://github.com/realm/SwiftLint#installation).

## Release Process

This SDK follows [Semantic Versioning](https://semver.org/). The release process will be automated via GitHub Actions.

## Analytics

Client analytics will be collected via Lighthouse/FPTI.
