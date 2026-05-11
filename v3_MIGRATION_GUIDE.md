# v3 Migration Guide

## Nullability changes

### `CoreSDKError.code` — `Int?` → `Int`

`code` is no longer optional. If your error-handling code nil-checks or
optional-chains this property, remove the unwrap:

```swift
// Before (v2)
if let code = error.code {
    print(code)
}

// After (v3)
print(error.code)
```

### `CoreSDKError.domain` — `String?` → `String`

`domain` is no longer optional. Remove any optional unwrapping:

```swift
// Before (v2)
guard let domain = error.domain else { return }

// After (v3)
let domain = error.domain
```

### Unchanged

`CoreSDKError.errorDescription` remains `String?` (required by the
`LocalizedError` protocol).
