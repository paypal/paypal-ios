How to move an existing **PayPal Mobile SDK V2 (2.x)** iOS integration to **V3.0.0**. The largest changes are in PayPal Checkout: the client was replaced with a new class in a new module, checkout is now session-first, `CoreConfig` requires a `merchantID`, return URLs moved into a URL config, and App Switch now requires Universal Links (V2's web flow used a hardcoded callback scheme for its own redirects).

## What's changed (PayPal Checkout)

| Area | V2 (2.x) | V3 |
| --- | --- | --- |
| Client class | `PayPalWebCheckoutClient` (module `PayPalWebPayments`) | `PayPalClient` (module `PayPalPayments`) |
| `CoreConfig` | client ID + environment | adds **required** `merchantID`, optional `bnCode` |
| Session | none | `createPayPalSession(sessionType:userIdentity:urlConfig:userAction:)` is **required before** `start()` |
| Return URLs | hardcoded `sdk.ios.paypal` callback scheme | `PayPalURLConfig` passed to `createPayPalSession()`; App Switch uses Universal Links |
| `start()` | `start(request:)` | `start(orderID:completion:)` |
| Result | completion / delegate | completion with `.success` / `.failure` (cancellation is a `.failure` — check `PayPalError.isCheckoutCanceled(error)` / `isVaultCanceled(error)`) |
| Return handling | handled internally by `ASWebAuthenticationSession` | forward the Universal Link via `handleReturnURL(url)` |

Card (ACDC) and Venmo keep their own clients; the main change they inherit is the `merchantID` on `CoreConfig`. Card's `approveOrder()` still resolves 3DS inline on iOS.

## Before you upgrade

* Get your **merchant ID** (the encrypted merchant account ID) from the [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/) — it is now required to initialize the SDK.
* Add an **Associated Domains** entitlement and serve an AASA file for your return domain — V3 App Switch returns via Universal Links, whereas V2's web flow used the hardcoded `sdk.ios.paypal` scheme for its own redirect. See [Install & Setup (iOS)](install-and-setup.md).
* Toolchain is unchanged: Xcode 15+, iOS 14+, Swift 5.9+.

## Update the dependency

Bump `CorePayments` and swap the PayPal Checkout product for its V3 successor — the module was renamed along with the client:

```ruby
# Podfile
pod 'PayPal/CorePayments', '~> 3.0'
pod 'PayPal/PayPalPayments', '~> 3.0'   # was PayPal/PayPalWebPayments in V2
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
+ let client = PayPalClient(config: config)
+ let urlConfig = PayPalURLConfig(
+     returnAppURL: URL(string: "https://example.com/merchant-app/return")!,
+     cancelAppURL: URL(string: "https://example.com/merchant-app/cancel")!,
+     fallbackSchemeURL: URL(string: "merchantapp://return")!
+ )

  func onPayPalButtonTapped() async throws {
+     // NEW: prepare the session before start()
+     client.createPayPalSession(
+         sessionType: .checkout,
+         userIdentity: PayPalUserIdentity(email: "buyer@example.com", phone: nil),
+         urlConfig: urlConfig,
+         userAction: .continue
+     )
      let orderID = try await myServer.createOrder()
-     client.start(request: PayPalWebCheckoutRequest(orderID: orderID)) { result in /* ... */ }
+     client.start(orderID: orderID) { result in
+         switch result {
+         case .success(let checkout): captureOrder(checkout.orderID)
+         case .failure(let error):
+             if PayPalError.isCheckoutCanceled(error) {
+                 showCheckoutScreen()
+             } else {
+                 showError(error.localizedDescription)
+             }
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

Add the custom-scheme `fallbackSchemeURL` under `CFBundleURLTypes` (optional on `PayPalURLConfig`, but you should always set it), and declare `paypal` under `LSApplicationQueriesSchemes` so the SDK can detect the PayPal app. Add the Associated Domains entitlement for your return domain. (V2's web flow needed none of these for PayPal Checkout because its return handling was internal to `ASWebAuthenticationSession`, built on the hardcoded `sdk.ios.paypal` scheme.) See [Install & Setup (iOS)](install-and-setup.md).

Note that `sdk.ios.paypal` isn't retired in V3 — it's still the SDK's internal callback scheme for Card's 3D Secure `ASWebAuthenticationSession` challenge, and it also still backs the PayPal Checkout in-app-browser fallback's own redirect internally. What changed is the buyer-facing, merchant-configured return path for PayPal Checkout and Vault: that's now Universal Links (with `fallbackSchemeURL` as backup), not something built on `sdk.ios.paypal` that you need to register or handle yourself.

## Verify the upgrade

* The project compiles with `PayPalClient` (module `PayPalPayments`) and no references to `PayPalWebCheckoutClient` or `PayPalWebPayments` remain.
* A sandbox checkout completes end to end: `createPayPalSession(sessionType:)` → `start(orderID:)` → return via `handleReturnURL(url)` → capture.
* `sessionNotStarted` does not occur (confirms `createPayPalSession()` runs before `start()`).

If something breaks after upgrading, see [Troubleshooting (iOS)](troubleshooting.md).

## Related

* [Install & Setup (iOS)](install-and-setup.md)
* [PayPal Checkout — Integration Guide (iOS)](paypal-checkout.md)
* [Troubleshooting (iOS)](troubleshooting.md)
