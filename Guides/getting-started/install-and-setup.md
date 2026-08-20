Complete these core setup steps once. Then integrate any payment method — PayPal Checkout or Card — using its guide; each one starts from the setup here and adds only what is specific to that method.

## Requirements

* A PayPal developer account, a **client ID**, and your **merchant ID** (the encrypted merchant account ID, required and distinct from your client ID) from the [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/).
* A server-side integration that can create and capture orders ([Orders v2 API](https://developer.paypal.com/docs/api/orders/v2/)), and — for vault flows — create setup tokens and payment tokens.
* **Universal Links** configured for your return URL before testing.
* Xcode 15+, iOS 14+, Swift 5.9+.

## Step 1: Add the SDK

The SDK ships as per-feature products — add only what you use. Add `FraudProtection` (device data, used to reduce declines) plus the product for each payment method you integrate. With CocoaPods:

```ruby
# Podfile
pod 'PayPal/CorePayments'
pod 'PayPal/FraudProtection'      # device data (risk signals)

# Add the product(s) for the method(s) you integrate:
pod 'PayPal/PayPalPayments'       # PayPal Checkout + Vault
pod 'PayPal/PaymentButtons'       # PayPal buttons
# pod 'PayPal/CardPayments'       # Card (ACDC)
```

Or add the `paypal-ios` Swift Package and include the matching products.

## Step 2: Initialize CoreConfig

Every client (`PayPalClient`, `CardClient`) is built from a single `CoreConfig`. No network calls occur at initialization.

```swift
let config = CoreConfig(
    clientID:    "<YOUR_CLIENT_ID>",
    environment: .sandbox,               // .live for production
    merchantID:  "<YOUR_MERCHANT_ID>",   // Required — encrypted merchant account ID
    bnCode:      nil                     // Partner integrations only
)
```

Reuse this `config` across every method client. Switch `.sandbox` to `.live` for production.

## Step 3: Register your return links

PayPal checkout sends the buyer to the PayPal app (or an in-app browser) and back to your app via a Universal Link. In **App Target › Signing & Capabilities › Associated Domains**, add `applinks:example.com` and serve your AASA file at `https://example.com/.well-known/apple-app-site-association`. One domain covers both your return and cancel URLs.

Register the custom-scheme fallback under `CFBundleURLTypes`, and declare the PayPal app scheme under `LSApplicationQueriesSchemes` so the SDK can detect it. `fallbackSchemeURL` is optional on `PayPalURLConfig`, but you should always set it — without it, a buyer whose Universal Link fails to open your app has no way back to checkout:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array><string>merchantapp</string></array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>paypal</string>
</array>
```

Define the matching URL config once; you pass it to each method's session or checkout call:

```swift
let urlConfig = PayPalURLConfig(
    returnAppURL:      URL(string: "https://example.com/merchant-app/return")!,
    cancelAppURL:      URL(string: "https://example.com/merchant-app/cancel")!,
    fallbackSchemeURL: URL(string: "merchantapp://return")   // Optional; see note above
)
```

> Card (ACDC) resolves its 3D Secure challenge in-process via `ASWebAuthenticationSession` and needs **no** Associated Domains or custom-scheme registration — see the Card guide.

## Next steps

With setup done, integrate a payment method:

* **PayPal Checkout** — One-Time Checkout, Vault (with/without purchase), Pay Later / PayPal Credit
* **Card (ACDC)** — card payments and vaulting

## Related

* [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/)
* [Orders v2 API](https://developer.paypal.com/docs/api/orders/v2/)
