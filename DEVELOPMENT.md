# PayPal iOS Development Notes

This document outlines development practices that we follow while developing this SDK.

## SwiftLint

Ensure that you have [SwiftLint](https://github.com/realm/SwiftLint) installed as we utilize it within our project.

To install via [Homebrew](https://brew.sh/) run:
```
brew install swiftlint
```
Our Xcode workspace has a `Run Phase` which integrates in `SwiftLint` so the only prerequisite is installing via `Homebrew`.

## Protocol Extraction Guidelines

Prefer concrete types. Only extract a protocol when it earns its keep:

- **2+ real conformers** — the abstraction has more than one production implementation.
- **A public API seam** — consumers outside the SDK need to inject their own implementation.
- **A distinct, non-trivial testable concern** — the protocol lets a test isolate one layer of behavior (e.g. request construction) from another (e.g. network I/O) that would otherwise be entangled in a single test.

A protocol with exactly one production conformer and one consumer is not automatically bloat — `CheckoutOrderConfirming`, `ClientConfigUpdating`, and `VaultedTokenSaving` are 1:1 but each isolates a distinct testable concern for its consuming client, and `HTTPClient`/`URLSessionProtocol` are 1:1 but isolate REST/GraphQL request construction from raw `URLSession` I/O — collapsing either would force one test suite to cover both concerns. Avoid extracting a protocol reflexively "for testability" when the type could just be constructed directly in tests, or when the resulting mock never diverges in behavior from the real thing.
