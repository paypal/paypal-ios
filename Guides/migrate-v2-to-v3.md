How to move an existing **PayPal Mobile SDK V2 (2.x)** iOS integration to **V3.0.0**. The largest changes are in PayPal Checkout: the client was renamed, checkout is now session-first, `CoreConfig` requires a `merchantID`, return URLs moved into a URL config, and App Switch now requires Universal Links (V2's web flow used a hardcoded callback scheme).

> **Preview — confirm before you rely on it.** V3.0.0 is not yet released. This guide is derived from the current V3 integration guides and the published 2.x API; confirm the exact deltas against the official V3 release notes when V3 ships.

## What's changed (PayPal Checkout)

| Area | V2 (2.x) | V3 |
| --- | --- | --- |
| Client class | `PayPalWebCheckoutClient` | `PayPalWebClient` |
| `CoreConfig` | client ID + environment | adds **required** `merchantID`, optional `bnCode` |
| Session | none | `createPayPalSession()` is **required before** `start()` |
| Return URLs | hardcoded `sdk.ios.paypal` callback scheme | `PayPalURLConfig` passed to `createPayPalSession()`; App Switch uses Universal Links |
| `start()` | `start(request:)` | `start(orderID:completion:)` |
| Result | completion / delegate | completion with `.success` / `.cancel` / `.failure` |
| Return handling | handled internally by `ASWebAuthenticationSession` | forward the Universal Link via `handleReturnURL(url)` |

Card (ACDC) and Venmo keep their own clients; the main change they inherit is the `merchantID` on `CoreConfig`. Card's `approveOrder()` still resolves 3DS inline on iOS.

## Before you upgrade

* Get your **merchant ID** (the encrypted merchant account ID) from the [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/) — it is now required to initialize the SDK.
* Add an **Associated Domains** entitlement and serve an AASA file for your return domain — V3 App Switch returns via Universal Links, whereas V2's web flow used the hardcoded `sdk.ios.paypal` scheme. See [Install & Setup (iOS)](install-and-setup.md).
* Toolchain is unchanged: Xcode 15+, iOS 14+, Swift 5.9+.

## Update the dependency

Bump each PayPal product to the V3 release (product names are unchanged):

```ruby
# Podfile
pod 'PayPal/CorePayments', '~> 3.0'
pod 'PayPal/PayPalWebPayments', '~> 3.0'
pod 'PayPal/PaymentButtons', '~> 3.0'
pod 'PayPal/FraudProtection', '~> 3.0'
```

## Migrate PayPal Checkout

Use this diff to guide the change:

```diff
  let config = CoreConfig(
      clientID: "<CLIENT_ID>",
+     merchantID: "<MERCHANT_ID>",   // now required, distinct from your client ID
      environment: .sandbox
  )

- let client = PayPalWebCheckoutClient(config: config)
+ let client = PayPalWebClient(config: config)
+ let urlConfig = PayPalURLConfig(
+     returnAppUrl: "https://example.com/merchant-app/return",
+     cancelAppUrl: "https://example.com/merchant-app/cancel",
+     fallbackSchemeUrl: "merchantapp://return"
+ )

  func onPayPalButtonTapped() async throws {
+     // NEW: prepare the session before start()
+     client.createPayPalSession(
+         userIdentity: PayPalUserIdentity(email: "buyer@example.com", phone: nil),
+         urlConfig: urlConfig,
+         userAction: .continue
+     )
      let orderID = try await myServer.createOrder()
-     client.start(request: PayPalWebCheckoutRequest(orderID: orderID)) { result in /* ... */ }
+     client.start(orderID: orderID) { result in
+         switch result {
+         case .success(let checkout): captureOrder(checkout.orderID)
+         case .cancel:                showCheckoutScreen()
+         case .failure(let error):    showError(error.localizedDescription)
+         }
+     }
  }

+ // NEW in V3: forward the Universal Link return to the SDK
+ func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
+     guard let url = userActivity.webpageURL else { return }
+     client.handleReturnURL(url)
+ }
```

## Info.plist and entitlements

Add the required custom-scheme `fallbackSchemeUrl` under `CFBundleURLTypes`, and declare `paypal` under `LSApplicationQueriesSchemes` so the SDK can detect the PayPal app. Add the Associated Domains entitlement for your return domain. (V2's web flow needed none of these because it used the hardcoded `sdk.ios.paypal` scheme.) See [Install & Setup (iOS)](install-and-setup.md).

## Verify the upgrade

* The project compiles with `PayPalWebClient` and no references to `PayPalWebCheckoutClient` remain.
* A sandbox checkout completes end to end: `createPayPalSession()` → `start(orderID:)` → return via `handleReturnURL(url)` → capture.
* `sessionNotStarted` does not occur (confirms `createPayPalSession()` runs before `start()`).

If something breaks after upgrading, see [Troubleshooting (iOS)](troubleshooting.md).

## Related

* [Install & Setup (iOS)](install-and-setup.md)
* [PayPal Checkout — Integration Guide (iOS)](paypal-checkout.md)
* [Troubleshooting (iOS)](troubleshooting.md)
