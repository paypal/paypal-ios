# v3 API Audit — Swift API Design Guidelines

Audit of all public symbols across the PayPal iOS SDK, evaluated against
the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

**Branch:** `v3/api-design-guidelines-audit` (base: `v3-beta`)

---

## Summary

| Metric | Count |
|--------|-------|
| Public symbols audited | 163 |
| Proposed renames | 26 |
| Documentation gaps (missing `///`) | 48 |

---

## Target: CorePayments

| # | Symbol | Kind | Current | Proposed | Rationale | Risk |
|---|--------|------|---------|----------|-----------|------|
| 1 | `Environment.toString` | computed var | `toString` | `description` (conform to `CustomStringConvertible`) | `toString` is Java/Obj-C convention; Swift uses `description`. The property already returns the same value `rawValue` would for a `String`-backed enum. | Low — internal-facing (`@_documentation(visibility: private)`) but the name is a clear guideline violation. |
| 2 | `Environment.graphQLURL` | computed var | `graphQLURL` | — | OK — acronym `URL` follows Apple conventions. | — |
| 3 | `Environment.paypalVaultCheckoutURL` | computed var | `paypalVaultCheckoutURL` | `payPalVaultCheckoutURL` | Inconsistent capitalisation of "PayPal" — other symbols use `payPal` (camelCase). | Low |
| 4 | `CoreConfig.environment` | let | — | — | OK — clear. Missing `///` doc comment. | — |
| 5 | `CoreConfig.clientID` | let | — | — | OK — clear. Missing `///` doc comment. | — |
| 6 | `CoreConfig.init(clientID:environment:)` | init | — | — | OK. Missing `///` doc comment. | — |
| 7 | `CoreSDKError.init(code:domain:errorDescription:)` | init | — | — | OK. Missing `///` doc comment. | — |
| 8 | `NetworkingError.unknownError` | static let | `unknownError` | `unknown` | Redundant "Error" suffix — the type is already `NetworkingError`. | Low — `@_documentation(visibility: private)`. |
| 9 | `NetworkingError.urlSessionError` | static let | `urlSessionError` | `urlSession` | Same "Error" suffix redundancy. | Low |
| 10 | `NetworkingError.jsonDecodingError` | static let (closure) | `jsonDecodingError` | `jsonDecoding` | Same. Also note: this is a closure `(String) -> CoreSDKError`, not a value — naming doesn't clarify that. | Low |
| 11 | `NetworkingError.invalidURLResponseError` | static let | `invalidURLResponseError` | `invalidURLResponse` | Same "Error" suffix. | Low |
| 12 | `NetworkingError.noResponseDataError` | static let | `noResponseDataError` | `responseDataMissing` | "no" prefix reads awkwardly; use adjective form. Also drop "Error". | Low |
| 13 | `NetworkingError.invalidURLRequestError` | static let | `invalidURLRequestError` | `invalidURLRequest` | Same "Error" suffix. | Low |
| 14 | `NetworkingError.serverResponseError` | static let (closure) | `serverResponseError` | `serverResponse` | Same. Closure type — same concern as #10. | Low |
| 15 | `CorePaymentsError.urlEncodingFailed` | static let | — | — | OK — no redundant suffix. | — |
| 16 | `AnalyticsService.orderID` | public var | — | — | Missing `///` doc comment. | — |
| 17 | `AnalyticsService.setupToken` | public var | — | — | Missing `///` doc comment. | — |

### CorePayments — documentation-only gaps (no rename needed)

The following public symbols lack `///` doc comments:

- `CoreConfig.environment`, `CoreConfig.clientID`, `CoreConfig.init(clientID:environment:)`
- `CoreSDKError.init(code:domain:errorDescription:)`
- `AnalyticsService.orderID`, `AnalyticsService.setupToken`, `AnalyticsService.init(coreConfig:orderID:)`, `AnalyticsService.init(coreConfig:setupToken:)`
- `Environment` (enum itself), `Environment.graphQLURL`
- All `NetworkingError` static properties (8)
- `WebAuthenticationSession` (class + `start(url:context:sessionDidDisplay:sessionDidComplete:)`)
- `PayPalCoreConstants` (enum itself), `PayPalCoreConstants.callbackURLScheme`
- `HTTPRequest.init(headers:method:url:body:)`
- `HTTPNetworkingClient.init(coreConfig:)` (convenience)
- `HTTPResponseParser` (class + all 3 public methods)
- `NetworkingClient.fetch(request:)`, `NetworkingClient.fetch(request:clientContext:)`
- `URLSessionProtocol.performRequest(with:)`, `URLSession.performRequest(with:)`
- `GraphQLHTTPResponse.data`
- `GraphQLRequest.init(query:variables:queryNameForURL:)`
- `RESTRequest` (struct + init)
- `UpdateClientConfigAPI.init(coreConfig:)`, `UpdateClientConfigAPI.updateClientConfig(token:fundingSource:)`

---

## Target: CardPayments

| # | Symbol | Kind | Current | Proposed | Rationale | Risk |
|---|--------|------|---------|----------|-----------|------|
| 18 | `SCA.scaAlways` | enum case | `scaAlways` | `always` | Redundant type-name prefix — `SCA.scaAlways` stutters; `SCA.always` reads naturally. | **Medium** — public API, affects merchant call sites. |
| 19 | `SCA.scaWhenRequired` | enum case | `scaWhenRequired` | `whenRequired` | Same prefix redundancy — `SCA.whenRequired` reads better. | **Medium** — same as above. |
| 20 | `CardError.unknownError` | static let | `unknownError` | `unknown` | Redundant "Error" suffix in an error type. | Low |
| 21 | `CardError.encodingError` | static let | `encodingError` | `encoding` | Same. | Low |
| 22 | `CardError.threeDSecureError` | static let (closure) | `threeDSecureError` | `threeDSecure` | Same. Closure `(Error) -> CoreSDKError`. | Low |
| 23 | `CardError.threeDSecureURLError` | static let | `threeDSecureURLError` | `threeDSecureURL` | Same. | Low |
| 24 | `CardError.threeDSecureCanceledError` | static let | `threeDSecureCanceledError` | `threeDSecureCanceled` | Same. | Low |
| 25 | `CardError.noVaultTokenDataError` | static let | `noVaultTokenDataError` | `vaultTokenDataMissing` | "no" prefix reads awkwardly + redundant "Error" suffix. | Low |
| 26 | `CardError.vaultTokenError` | static let | `vaultTokenError` | `vaultToken` | Redundant "Error" suffix. | Low |
| 27 | `CardError.nilGraphQLClientError` | static let | `nilGraphQLClientError` | `graphQLClientUnavailable` | "nil" is an implementation detail; "unavailable" is user-facing language. Drop "Error" suffix. | Low |
| 28 | `CardError` | enum | — | — | Missing `///` doc comment on the enum itself. | — |
| 29 | `CardRequest` | struct | — | — | Missing `///` doc comment on the struct itself. | — |

### CardPayments — documentation-only gaps

- `CardError` (enum type)
- `CardRequest` (struct type)
- `CardAnalyticsEvent.ApproveOrder` (nested enum + all 9 cases + `eventName`)
- `CardAnalyticsEvent.Vault` (nested enum + all 9 cases + `eventName`)
- `PaymentSource.Card` (nested struct)
- `PaymentSource.Card.AuthenticationResult.liabilityShift`, `.threeDSecure`
- `PaymentSource.Card.AuthenticationResult.ThreeDSecure.enrollmentStatus`, `.authenticationStatus`

---

## Target: PayPalWebPayments

| # | Symbol | Kind | Current | Proposed | Rationale | Risk |
|---|--------|------|---------|----------|-----------|------|
| 30 | `PayPalWebCheckoutFundingSource.paylater` | enum case | `paylater` | `payLater` | Violates camelCase — two words concatenated without capital. Already tagged `// NEXT_MAJOR_VERSION`. v3 is the right time. | **Medium** — public API, affects merchant call sites. Raw value `"paylater"` must be preserved for wire compatibility. |
| 31 | `PayPalError.webSessionError` | static let (closure) | `webSessionError` | `webSession` | Redundant "Error" suffix. | Low |
| 32 | `PayPalError.payPalURLError` | static let | `payPalURLError` | `payPalURL` | Same. | Low |
| 33 | `PayPalError.malformedResultError` | static let | `malformedResultError` | `malformedResult` | Same. | Low |
| 34 | `PayPalError.payPalVaultResponseError` | static let | `payPalVaultResponseError` | `payPalVaultResponse` | Same. | Low |
| 35 | `PayPalError.checkoutCanceledError` | static let | `checkoutCanceledError` | `checkoutCanceled` | Same. | Low |
| 36 | `PayPalError.vaultCanceledError` | static let | `vaultCanceledError` | `vaultCanceled` | Same. | Low |
| 37 | `PayPalWebCheckoutClient` | class | — | — | Missing `///` doc comment on the class itself. | — |
| 38 | `PayPalVaultResult.tokenID` | let | — | — | Missing `///` doc comment. | — |
| 39 | `PayPalVaultResult.approvalSessionID` | let | — | — | Missing `///` doc comment. | — |
| 40 | `PayPalVaultRequest.url` | let | deprecated | **Remove** (v3 breaking change window) | Property is always `nil`, deprecated in v2. Tagged `NEXT_MAJOR_VERSION`. | Low — already deprecated. |
| 41 | `PayPalVaultRequest.init(url:setupTokenID:)` | init | deprecated | **Remove** | Same — deprecated init. | Low |

### PayPalWebPayments — documentation-only gaps

- `PayPalWebCheckoutClient` (class type)
- `PayPalVaultResult.tokenID`, `.approvalSessionID`
- `PayPalError` (enum type) + all 6 static error properties
- `PayPalWebAnalyticsEvent.Checkout` (nested enum + all 6 cases + `eventName`)
- `PayPalWebAnalyticsEvent.Vault` (nested enum + all 6 cases + `eventName`)

---

## Target: PaymentButtons

| # | Symbol | Kind | Current | Proposed | Rationale | Risk |
|---|--------|------|---------|----------|-----------|------|
| 42 | `PayPalPayLaterButton.init(..., _:)` | init | unlabeled trailing `_ action:` | `action:` (labeled) | Per Swift API guidelines, closure parameters should have descriptive labels for clarity at call site. The `_` hides the parameter's purpose. | Low — SwiftUI internal convenience. |
| 43 | `PayPalPayLaterButton.Representable.init(..., _:)` | init | same | `action:` | Same rationale. | Low |
| 44 | `PayPalButton.Representable.init(..., _:)` | init | same | `action:` | Same rationale. | Low |
| 45 | `PayPalCreditButton.Representable.init(..., _:)` | init | same | `action:` | Same rationale. | Low |
| 46 | `PaymentButtonColor` | enum | — | — | Missing `///` doc comment on the enum itself. | — |

### PaymentButtons — documentation-only gaps

- `PaymentButtonColor` (enum type)
- `PaymentButtonFundingSource` cases (3): `.payPal`, `.payLater`, `.credit`
- `PayPalButton.Color` cases (5): `.gold`, `.white`, `.black`, `.silver`, `.blue`
- `PayPalCreditButton.Color` cases (3): `.white`, `.black`, `.darkBlue`
- `PayPalPayLaterButton.Color` cases (5): `.gold`, `.white`, `.black`, `.silver`, `.blue`
- `PaymentButtonAnalyticsEvent` cases (2): `.initialized`, `.tapped` + `eventName`
- `PaymentButtonEdges.description`, `PaymentButtonColor.description`, `PaymentButtonSize.description`
- `PaymentButton.init(fundingSource:color:edges:size:insets:label:)` (required init)
- `Coordinator.init(action:)`

---

## Cross-Cutting Concerns

### Symbols shared with paypal-android or external developer documentation

The following types are part of the public integration contract and their shapes
may be referenced in PayPal developer documentation or have Android SDK counterparts:

| Symbol | Notes |
|--------|-------|
| `CardResult` | Order ID + status shape — matched by Android. **Do not rename properties.** |
| `CardVaultResult` | Setup token ID + status — matched by Android. |
| `PayPalWebCheckoutResult` | Order ID + payer ID — matched by Android. |
| `PayPalVaultResult` | Token ID + approval session ID — matched by Android. |
| `CoreConfig` | Client ID + environment — matched by Android. |
| `SCA` | Enum name and raw values sent to API — **renaming cases is safe** as long as raw `String` values are preserved. |

### Pattern: `@_documentation(visibility: private)` + `public`

14 symbols are marked `@_documentation(visibility: private)` but declared `public`.
These are intentionally public for cross-module access within the SDK but not intended
for merchant consumption. This is an acceptable Swift pattern and does not require changes,
but adding `///` doc comments explaining the internal-only intent would improve clarity.

Affected: `AnalyticsService`, `AnalyticsEventName`, `PayPalCoreConstants`,
`WebAuthenticationSession`, `CorePaymentsError`, `NetworkingError`, `HTTPHeader`,
`HTTPResponse`, `HTTPResponseParser`, `RESTRequest`, `ClientConfigResponse`,
`GraphQLHTTPResponse`, `Coordinator`, `PaymentButtonAnalyticsEvent`.

---

## Top 10 Highest-Impact Proposed Renames

| Rank | Current | Proposed | Target | Rationale |
|------|---------|----------|--------|-----------|
| 1 | `SCA.scaAlways` | `SCA.always` | CardPayments | Stuttering type prefix in public merchant-facing API. `SCA.always` reads as an English phrase. |
| 2 | `SCA.scaWhenRequired` | `SCA.whenRequired` | CardPayments | Same stuttering prefix. `SCA.whenRequired` is clear and concise. |
| 3 | `PayPalWebCheckoutFundingSource.paylater` | `.payLater` | PayPalWebPayments | camelCase violation — already tagged `NEXT_MAJOR_VERSION`. v3 is that version. |
| 4 | `Environment.toString` | `.description` (via `CustomStringConvertible`) | CorePayments | Java-style naming; Swift idiom is `description`. |
| 5 | `CardError.noVaultTokenDataError` | `.vaultTokenDataMissing` | CardPayments | "no" prefix + redundant "Error" suffix. |
| 6 | `CardError.nilGraphQLClientError` | `.graphQLClientUnavailable` | CardPayments | "nil" is an implementation detail leaked into API naming. |
| 7 | `NetworkingError.noResponseDataError` | `.responseDataMissing` | CorePayments | "no" prefix + redundant "Error" suffix. |
| 8 | `PayPalVaultRequest.url` / `init(url:setupTokenID:)` | **Remove** | PayPalWebPayments | Deprecated property always `nil`. v3 is the breaking-change window. |
| 9 | All `*Error` suffixed error constants (19 total) | Drop `Error` suffix | All | Systematic redundancy — type context already establishes these are errors. |
| 10 | Button `init(..., _:)` closures (4 total) | `init(..., action:)` | PaymentButtons | Unnamed closure parameter hides purpose; `action:` label adds clarity. |

---

## STOP — review the audit before applying

Phase 2 (applying renames and doc additions) will not begin until this audit
is reviewed and approved. Please comment on which proposals to accept, reject,
or modify before implementation proceeds.
