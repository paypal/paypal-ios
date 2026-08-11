This guide shows you how to accept a **Venmo payment** (One-Time Checkout) in your iOS app with PayPal Mobile SDK V3.0.0. Venmo checkout uses its own client, `VenmoClient`, and reuses the Universal Link and fallback scheme you registered in Install & Setup. When the buyer taps your Venmo button, checkout opens the Venmo app if it is installed and the buyer is eligible; otherwise it falls back to an in-app browser automatically. **Venmo supports One-Time Checkout only** — vault flows are not supported for Venmo.

> **⚠ Status — not in the published iOS SDK.** The iOS SDK on `main` has no Venmo module: `Package.swift` ships only CorePayments, PaymentButtons, PayPalWebPayments, CardPayments, and FraudProtection (the `feature/venmo-app-switch` branch is the same). The API on this page — `VenmoClient`, `VenmoCheckoutRequest`, and especially the `appSwitchIfEligible` flag — is **provisional and unverified against shipped iOS code**; confirm it with the SDK / Venmo team before relying on it. Venmo currently exists as a module in the **Android** SDK, not iOS.

> **Before you start:** complete [Install & Setup (iOS)](install-and-setup.md).

## Overview

Unlike PayPal Checkout, Venmo does **not** use `createPayPalSession()`. Everything needed for the transaction is passed in a single `VenmoCheckoutRequest` when you call `start()`.

```mermaid
sequenceDiagram
    participant App as Your App
    participant SDK as PayPal SDK
    participant Venmo as Venmo (app or browser)
    participant Server as Your Server

    Note over App,Server: Buyer taps your Venmo button
    App->>Server: Create order with payment_source.venmo (Orders v2)
    Server-->>App: orderID
    App->>SDK: venmoClient.start(VenmoCheckoutRequest(orderID, appSwitchIfEligible: true, returnURL))
    SDK->>Venmo: Open Venmo (app if installed & eligible, else ASWebAuthenticationSession)
    Venmo-->>App: Return to your app (Universal Link)
    App->>SDK: venmoClient.handleReturnURL(url)
    SDK->>App: .success(orderID, payerID) or .failure (cancel via VenmoError.isCheckoutCanceled)
    App->>Server: Capture order (Orders v2)
```

## Before you begin

Complete [Install & Setup (iOS)](install-and-setup.md). For Venmo specifically:

* Add the `VenmoPayments` product.
* Construct the client from the `CoreConfig` you built in setup:

```swift
let venmoClient = VenmoClient(config: config)
```

* Venmo reuses your Universal Link and `fallbackSchemeUrl` from setup — no extra Associated Domains or Info.plist changes — as long as your Venmo return/cancel URLs sit under the same domain.

## Server: create the order with the Venmo payment source

Call the Orders v2 API server-to-server with a **Venmo** payment source. `app_switch_context.source: "NATIVE_APP"` tells Venmo the order originated from a native app-switch flow. Return only the order ID to your app.

```shell
curl -X POST https://api-m.sandbox.paypal.com/v2/checkout/orders \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <access-token>' \
  -d '{
    "intent": "CAPTURE",
    "purchase_units": [ { "amount": { "currency_code": "USD", "value": "49.99" } } ],
    "payment_source": { "venmo": { "experience_context": {
      "return_url": "https://example.com/merchant-app/return",
      "cancel_url": "https://example.com/merchant-app/cancel",
      "app_switch_context": { "source": "NATIVE_APP" }
    } } }
  }'
```

## Integrate Venmo

### Step 1: Start Venmo checkout

On the buyer's tap, create the order (with the Venmo payment source above), build a `VenmoCheckoutRequest`, and call `start()`. Set `appSwitchIfEligible` to `true` to allow the app-switch path; `returnURL` should match the `return_url` on the order.

```swift
let request = VenmoCheckoutRequest(
    orderID: orderID,
    appSwitchIfEligible: true,
    buyerCountry: "US",   // defaults to "US"
    currency: "USD",      // defaults to "USD"
    returnURL: "https://example.com/merchant-app/return"
)

venmoClient.start(request: request) { result in
    switch result {
    case .success(let checkout):
        captureOrder(checkout.orderID)   // checkout.payerID also available
    case .failure(let error):
        if VenmoError.isCheckoutCanceled(error) {
            showCheckoutScreen()
        } else {
            showError(error.localizedDescription)
        }
    }
}

// An async/await variant is also available:
// let result = try await venmoClient.start(request: request)
```

> **Provisional —** `appSwitchIfEligible` is unverified. This parameter could not be confirmed against the iOS SDK (no Venmo module is present on `main`). It also runs counter to PayPal Checkout's 2026 change that removed the equivalent client-side app-switch flag in favor of account-level gating. Confirm the real `VenmoCheckoutRequest` shape with the SDK team before using it.

### Step 2: Handle the return

Forward the incoming URL to the SDK from your scene continuation (or `.onOpenURL` in SwiftUI). This resolves the completion you passed to `start()`.

```swift
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard let url = userActivity.webpageURL else { return }
    venmoClient.handleReturnURL(url)
}
```

### Step 3: Capture the order

```swift
func captureOrder(_ orderID: String) {
    // POST /v2/checkout/orders/{orderID}/capture on your server
    myServer.captureOrder(orderID)
}
```

## Result handling

Venmo delivers a single `Result<VenmoCheckoutResult, CoreSDKError>`. Cancellation is represented as a failure, not a separate case — check for it with `VenmoError.isCheckoutCanceled(error)`.

| Outcome | How it is delivered | What you do |
| --- | --- | --- |
| **Success** | `.success` — `VenmoCheckoutResult` with `orderID` and `payerID` | Capture the order. |
| **Cancel** | `.failure` where `VenmoError.isCheckoutCanceled(error)` is `true` | Return the buyer to your checkout screen; no charge was made. |
| **Other failure** | `.failure` — e.g. `VenmoError.fundingEligibilityError` (Venmo not eligible on the web-fallback path), `venmoURLError`, or `malformedResultError` | Show `error.localizedDescription`. |

## Testing and go-live

Follow the same physical-device approach as PayPal App Switch, with two differences: sign in to the sandbox app with a **Venmo** (not just PayPal) test account, and create the order with the Venmo payment source shown above.

| Scenario | Expected result |
| --- | --- |
| **App switch — end to end** | With the Venmo app installed and eligible, the buyer switches to Venmo, approves, returns to your app, and the order captures. |
| **Web fallback — end to end** | With the Venmo app not installed (or `appSwitchIfEligible: false`), checkout completes in `ASWebAuthenticationSession` and the order captures. |
| Buyer cancels in Venmo | The completion resolves with a canceled failure (`VenmoError.isCheckoutCanceled`); no charge is made. |

### Go live

- [ ] Confirm the shipped iOS Venmo API (this guide is provisional — see the status note above).
- [ ] Switch `.sandbox` to `.live` and use your live client ID and merchant ID.
- [ ] Verify the Universal Link return and custom-scheme fallback work in a release build.
- [ ] Confirm success, cancel (`VenmoError.isCheckoutCanceled`), and other failures are handled.
- [ ] Contact your PayPal account team to enable Venmo for production traffic.

## Related

* [Install & Setup (iOS)](install-and-setup.md)
* [Troubleshooting (iOS)](troubleshooting.md)
* [Orders v2 API](https://developer.paypal.com/docs/api/orders/v2/)
