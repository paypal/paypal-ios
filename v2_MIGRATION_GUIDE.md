# Migrating from Delegates to Completion Handlers

## Overview
Version 2.0-beta of the SDK transitions from the delgate-based payment flows to completion handler-based flows. This change simplifies the integration and provides better compatibility with modern async/await patterns.

### Key Change

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
                // handle error
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
//Old (Delegate-based)
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
                // handle error
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
        } catch let error as CardClientError {
            switch error {
                case .threeDSecureCancellation:
                    handleCancellation()
                default:
                    handleError(error)
            }
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
            /// Payment successful
            handleSuccess(result)
        } catch let error as PayPalWebCheckoutClientError {
            switch error {
                case .paypalCancellationError:
                    handleCancellation()
                default:
                    handleError(error)
            }
        } catch {
            handleError(error)
        }
    }
}
```

## Migration Steps

### 1. Update SDK Version
- Update your dependency manager (CocoapPods, SPM, etc.) to the latest SDK version

### 2. Remove Delegate Implementation
```swift
// Remove delegate protocol confirmance
- class MyViewController: CardDelegate {
+ class MyViewController {

/// Remove delegate property assignment
-cardClient.delegate = self

// Remove delegate methods
- func card(_ cardClient: CardClient, didFinishWithResult result: CardResult) {
- func card(_ cardClient: CardCliet, didFinishWithError error: Error) {
- func cardDidCancel(_ cardClient: CardClient ) {
```

### 3. Update SDK Flow Implementation
```swift
// Option 1: Using completion handlers
func processPayment() {
    showLaodingIndicator()

    cardClient.approveORder(request: cardRequest) { [weak self] result, error in
        guard let self = self else { return }
        removeLoadingIndicator()

        if let error = error {
            switch error {
                case CardClientError.threeDSecureCancellation:
                    handleCancellation()
                default:
                    handleError(erorr)                
            }
            return
        }

        if let result = result {
            handleSuccess(result)
        }
    }
}
```
// Option 2: Using async/await
```swift
func processPayment() async {
    showLaodingIndicator()
    defer { removeLoadingIndicator() }

    do {
        let result = try await cardClient.approveOrder(request: cardReuqest)
        handleSuccess(result)
    } catch {
        handleError(error)
    }
}
```