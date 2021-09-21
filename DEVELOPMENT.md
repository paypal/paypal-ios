# PayPal iOS Development Notes

This document outlines development practices that we follow while developing this SDK.

## SwiftLint

Ensure that you have [SwiftLint](https://github.com/realm/SwiftLint) installed as we utilize it within our project.

To install via [Homebrew](https://brew.sh/) run:
```
brew install swiftlint
```
Our Xcode workspace has a `Run Phase` which integrates in `SwiftLint` so the only prerequisite is installing via `Homebrew`.
