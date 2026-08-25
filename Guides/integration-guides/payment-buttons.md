The SDK ships PayPal-branded buttons — `PayPalButton`, `PayPalPayLaterButton`, and `PayPalCreditButton` (the `PaymentButtons` product). Use these rather than building your own: they carry PayPal's wordmark, brand colors, typography (the PayPalOpen font), and accessibility. This guide covers adding, styling, and wiring a button; for the checkout it triggers, see [PayPal Checkout](paypal-checkout.md).

> **Before you begin:** complete [Install & Setup (iOS)](../getting-started/install-and-setup.md) and add the `PaymentButtons` product.

## Add a button

The button renders without an order or session.

**SwiftUI**

```swift
PayPalButton.Representable(color: .gold, size: .collapsed, label: .checkout) {
    beginCheckout()
}
```

**UIKit**

```swift
let payPalButton = PayPalButton(color: .gold, size: .collapsed, label: .checkout)
payPalButton.addTarget(self, action: #selector(beginCheckout), for: .touchUpInside)
```

## Customize

All customization is passed to the initializer (`PayPalButton.Representable` in SwiftUI, `PayPalButton` in UIKit):

| Parameter | Values | Default |
| --- | --- | --- |
| `color` | `PayPalButton.Color`: `.gold`, `.blue`, `.white`, `.black`, `.silver` | `.gold` |
| `label` | `PayPalButton.Label?`: `.none`, `.checkout`, `.buyNow`, `.payWith` | `nil` (wordmark only, same as `.none`) |
| `edges` | `PaymentButtonEdges` (defaults to `.softEdges`) | `.softEdges` |
| `size` | `PaymentButtonSize`: `.mini`, `.collapsed`, `.expanded`, `.full` | `.collapsed` |
| `insets` | `NSDirectionalEdgeInsets?` — padding around the content | `nil` |

Notes:

* `.gold` is the recommended default — PayPal's research shows it converts best. `.blue` is the preferred alternative; `.white`, `.black`, and `.silver` are secondary.
* `.white` renders with a border for contrast.
* Stick to these built-in options rather than recoloring or rebuilding the button — they keep you brand-compliant.
* For Pay Later or PayPal Credit, use `PayPalPayLaterButton` or `PayPalCreditButton`.

## Handle taps

In SwiftUI the trailing closure is your tap handler; in UIKit use `addTarget`. Start checkout from it:

```swift
func beginCheckout() {
    // prepare the session, create the order, call start() — see PayPal Checkout
}
```

What happens in `beginCheckout()` is covered in [PayPal Checkout — Integration Guide (iOS)](paypal-checkout.md). For Pay Later / PayPal Credit funding, see that guide's _Pay Later and PayPal Credit_ section.

## Accessibility and localization

The button sets its own accessibility label (combining the label text and wordmark), so VoiceOver announces it correctly. Ensure adequate contrast against its background and a large enough touch target.

## Related

* [Install & Setup (iOS)](../getting-started/install-and-setup.md)
* [PayPal Checkout — Integration Guide (iOS)](paypal-checkout.md)
* [Troubleshooting (iOS)](troubleshooting.md)
