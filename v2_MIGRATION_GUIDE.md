# Migrating from Delegates to Completion Handlers

## Overview
Version 2.0 of the SDK transitions from delgate-based flows to completion handler-based flows. This change simplifies the integration and provides better compatibility with modern async/await patterns.

### Key Changes

### Important Change: Cancellation Handling
In v2.0, cancellations (e.g., 3DS cancellations, PayPal web flow cancellations) are now returned as errors rather than as separate delegate methods. There are new helper static functions, to help you discern threeDSecure cancellation errors and PayPal web flow cancellation errors. 
- `CardError.threeDSecureCanceled(Error)` will return true for 3DS cancellation errors received during card payment or card vaulting flows. 
- `PayPalError.isCheckoutCanceled(Error)` will return true for user cancellation during PayPalWebCheckout session.
- `PayPalError.isVaultCanceled(Error)` will return true for user cancellation during PayPal vault session.

### CardClient Changes

```swift
// Old Delgate-based
class MyViewController: CardDelegate {
    func setupPayment() {
        let cardClient = CardClient(config: config)
        cardClient.delegate = self
        cardClient.approveOrder(request: cardRequest)
    }
   
    func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
        // Handle success
    }

    func card(_ cardClient: CardClient, didFinishWithError error: Error) {
        // Handle error
    }

    func cardDidCancel(_ cardClient: CardClient) {
        // Handle cancellation
    }
}

// New (Completion-based)
class MyViewController {
    func setupPayment() {
        let cardClient = CardClient(config: config)
        cardClient.approveOrder(request: cardRequest) { [weak self] result, error in
            if let error = error {
                // if threeDSecure is canceled by user
                if CardError.isThreeDSecureCanceled(error) {
                // handle cancel error
                } else {
                // handle other errors
                }
                return
             }
            if let result = result {
                // handle success
            }
        }
    }
}
```

### PayPalWebCheckoutClient Changes

```Swift
// Old (Delegate-based)
class MyViewController: PayPalWebCheckoutDelegate {
    func startPayPalFlow() {
        let payPalClient = PayPalWebCheckoutClient(config: config)
        payPalClient.delegate = self
        payPalClient.approveOrder(request: paypalRequest)
    }
   
    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult) {
        // Handle success
    }

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: Error) {
        // Handle error
    }

    func payPalDidCancel(_ payPalClient: PayPalCheckoutClient) {
        // Handle cancellation
    }
}

// New (Completion-based)
class MyViewController {
    func setupPayment() {
        let payPalClient = PayPalWebCheckoutClient(config: config)
        payPalClient.start(request: paypalRequest) { [weak self] result, error in
            if let error = error {
                // if PayPal webflow is canceled by user
                if PayPalError.isCheckoutCanceled(error) {
                // handle cancel error
                } else {
                // handle all other errors
                }
                return
            }
            if let result = result {
                // handle success
            }
        }
    }
}
```

## Async/Await 
The SDK now provides async/await support, offering a more concise way to handle asynchronous operations. 

### CardClient
```swift
class MyViewController {
    func setupPayment() async {
        let cardClient = CardClient(config: config)
        do {
            let result = try await cardClient.approveOrder(request: cardRequest)
            // payment successful
            handleSuccess(result)
        } catch {
            handleError(error)
        }
    }
}
```

### PayPalWebCheckoutClient
```swift
class MyViewController {
    func startPayPalFlow() async {
        let payPalClient = PayPalWebCheckoutClient(config: config)
        do {
            let result = try await payPalClient.start(request: paypalRequest)
            // Payment successful
            handleSuccess(result)
        } catch {
           handleError()
        }
    }
}
```

## Migration Steps

### 1. Update SDK Version
- Update your dependency manager (CocoaPods or SPM) to the latest SDK version

### 2. Remove Delegate Implementation
```diff
// Remove delegate protocol conformance
- class MyViewController: CardDelegate {
+ class MyViewController {

// Remove delegate property assignment
-cardClient.delegate = self

// Remove delegate methods
- func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
- func card(_ cardClient: CardClient, didFinishWithError error: Error) {
- func cardDidCancel(_ cardClient: CardClient ) {
```

### 3. Update SDK Flow Implementation

 Option 1: Using completion handlers
```swift
func processPayment() {
    showLoadingIndicator()

    cardClient.approveOrder(request: cardRequest) { [weak self] result, error in
        guard let self = self else { return }
        removeLoadingIndicator()

        if let error = error {
            handleError()
            return
        }

        if let result = result {
            handleSuccess(result)
        }
    }
}
```
 Option 2: Using async/await
```swift
func processPayment() async {
    showLoadingIndicator()
    defer { removeLoadingIndicator() }

    do {
        let result = try await cardClient.approveOrder(request: cardRequest)
        handleSuccess(result)
    } catch {
         handleError()
    }
}
```
