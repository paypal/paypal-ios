# Migration Guide to 3.0.0

This guide helps you migrate your code from version 2.x to 3.x.

## CorePayments

### `CoreConfig` initializer

`CoreConfig.init` now requires a `merchantID` parameter. An optional `bnCode` parameter has also been added for partner attribution.

```diff
- let config = CoreConfig(
-     clientID: "YOUR_CLIENT_ID",
-     environment: .sandbox
- )
+ let config = CoreConfig(
+     clientID: "YOUR_CLIENT_ID",
+     environment: .sandbox,
+     merchantID: "YOUR_MERCHANT_ID"
+ )
```

If you are a PayPal partner processing payments on behalf of merchants, also supply the BN (partner attribution) code issued to your platform:

```swift
let config = CoreConfig(
    clientID: "YOUR_CLIENT_ID",
    environment: .sandbox,
    merchantID: "YOUR_MERCHANT_ID",
    bnCode: "YOUR_BN_CODE"     // optional — only required for partner integrations
)
```
