Common problems integrating the PayPal Mobile SDK V3.0.0 on iOS, organized by symptom. For an error that happens inside one specific flow, also check that guide's **Result handling** section.

## Build and dependency

**Swift Package Manager or CocoaPods cannot resolve the PayPal products**

* Likely cause: the product name is wrong or not added.
* Fix: add `CorePayments` plus the products you use (`PayPalPayments`, `FraudProtection`, `PaymentButtons`, `VenmoPayments`, `CardPayments`). See [Install & Setup (iOS)](../getting-started/install-and-setup.md).

## Setup and initialization

`PayPalError.sessionNotStartedError` returned on `start()` or `vault()`

* Likely cause: `createPayPalSession()` was not called first.
* Fix: call `createPayPalSession(sessionType:userIdentity:urlConfig:userAction:)` on `PayPalClient` in your button's action, before or alongside order creation. See [PayPal Checkout](paypal-checkout.md).

**Auth or configuration errors right after** `start()`

* Likely cause: wrong `environment`, or an invalid/missing `merchantID` (required in V3 and distinct from your client ID).
* Fix: recheck `CoreConfig` — `clientID`, `merchantID`, and `.sandbox` vs `.live`.

## Return and redirect

**The buyer completes checkout but never returns to your app**

* Likely cause: your Universal Link is not associated with your domain, or the return/cancel URLs are not under the associated domain.
* Fix: confirm the **Associated Domains** entitlement (`applinks:example.com`) and that your AASA file is served at `https://<domain>/.well-known/apple-app-site-association`; keep return/cancel URLs on that domain. Setting `fallbackSchemeURL` (in `CFBundleURLTypes`) covers Universal Link delivery failures.

**The completion handler never fires after the buyer returns**

* Likely cause: the return URL was not forwarded to the SDK.
* Fix: call `checkoutClient.handleReturnURL(url)` (on your `PayPalClient`) from `scene(_:continue:)` (or `.onOpenURL` in SwiftUI).

**Checkout stayed in the in-app browser instead of opening the PayPal app**

* Likely cause: `LSApplicationQueriesSchemes` is missing `paypal`, or expected fallback — the buyer is not eligible, the PayPal app is not installed, the buyer is not in the US, or the identity email does not match the signed-in PayPal account.
* Fix: declare `paypal` under `LSApplicationQueriesSchemes`; to exercise the app-switch path in testing, meet all trigger conditions (see [PayPal Checkout](paypal-checkout.md) → Testing and go-live).

## Result and challenge

**Unexpected cancel, or a** `.failure` you expected to be a cancel

* Likely cause: cancellation is always surfaced as a `.failure`, never a separate `.cancel` case — for any of PayPal, Venmo, or Card.
* Fix: before treating a failure as an error, check `PayPalError.isCheckoutCanceled(error)` / `isVaultCanceled(error)` (PayPal), `VenmoError.isCheckoutCanceled(error)` (Venmo), or `CardError.isThreeDSecureCanceled(error)` (Card) and route the buyer back to checkout.

**Card fails with a 3DS URL error**

* Likely cause: `CardError.threeDSecureURLError` — the challenge URL failed iOS's PayPal 3DS validation. On `approveOrder()`, the SDK checks the URL is a genuine PayPal Helios `flow=3ds` page before opening it; on `vault()`, the check is slightly weaker — it only confirms the URL contains `helios`, without also requiring `flow=3ds`.
* Fix: confirm you are on a genuine PayPal environment and order; if it persists, capture the URL and contact support.

## Still stuck

* Re-check [Install & Setup (iOS)](../getting-started/install-and-setup.md).
* Look up exact signatures in the generated API reference (DocC).
* Run the sample app to compare against a known-good integration.
* Contact your PayPal account team or support.

## Related

* [Install & Setup (iOS)](../getting-started/install-and-setup.md)
* [PayPal Checkout — Integration Guide (iOS)](paypal-checkout.md)
* [Card / ACDC — Integration Guide (iOS)](card-acdc.md)
