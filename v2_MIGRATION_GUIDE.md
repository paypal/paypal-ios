# Migrating Guide to 2.0.0

This guide helps you migrate your code from version 1.x to 2.x

> **Note:**
> Most of the examples below show the changes introduced in **2.0.0-beta1** (new `CoreSDKError` wrapper types in **2.0.0-beta2**), which used completion signature of the form `(SomeResult?,CoreSDKError?) -> Void`.
> For **2.0.0 GA**, these methods now use `Result<SomeResult, CoreSDKError>` in their completion blocks.
> Please see the [What's New in 2.0.0](#whats-new-in-200) section below for updated code snippets.

## Overview
Version 2.0 of the SDK transitions from delgate-based flows to completion handler-based flows. This change simplifies the integration and provides better compatibility with modern async/await patterns.

### Error Handling in the SDK
This SDK uses `CoreSDKError` as its unified error type across all operations. All errors returned by the SDK, whether from card payments, PayPal flows, or networking operations, are instances of `CoreSDKError`.
This allows for consistent error handling across different payment methods and operations.

### Key Changes

### Important Change: Cancellation Handling
In v2.0, cancellations (e.g., 3DS cancellations, PayPal web flow cancellations) are now returned as errors rather than as separate delegate methods. 

### What's New in 2.0.0-beta2
- The `CoreSDKError` is now equatable, enabling direct comparison of errors:
```swift
// Now possible in 2.0.0-beta2
  if error == CardError.threeDSecureCanceledError {
     // Handle 3DS Cancellation
  }
  
// Instead of checking properties individually before and helper function in 2.0.0-beta1
```

- Public Access to Domain-Specific Error Enums: 
Previously internal error enums like `CardError` and `NetworkingError` are now public, along with their static properties that return `CoreSDKError` instances. This provides better discoverability and type safety when working with specific error cases.
```swift
public enum CardError {
  public static let threeDSecureCanceledError: CoreSDKError
  public static let encodingError: CoreSDKError
  //...other error constants
}

public enum NetworkingError {
  public static let urlSessionError: CoreSDKError
  public static let serverResponseError: (String) -> CoreSDKError
  //...other error constants
}
```

- Error Handling Examples

Using Completion Handlers
```swift
// Completion handlers return CoreSDKError, so no casting is needed in completion blocks
cardClient.vault(request) { result, error in
   if let error {
   // You can now use the public error enums directly
      switch error {
      case CardError.threeDSecureCanceledError:
      // Handle 3DS cancellation
      case NetworkingError.urlSessionError:
      // Handle netowrk error
      default:
      // Handle other errors
    }
    return
  }
  if let result {
    // Handle success
  }
}
```

Using Async/Await
```swift
do {
      let result = cardClient.vault(request)
      // handle success
   } catch let error as CoreSDKError {
      // Make sure to cast to CoreSDKError when using try-catch
      switch error {
      case CardError.threeDSecureCanceledError:
      // Handle 3DS cancellation
      case NetworkingError.urlSessionError:
      // Handle netowrk error
      default:
      // Handle other errors
      }
  } catch {
     // Handle unexpected errors
  }  
  
  // Alternative approach using if-else
  do {
     let result = try await cardClient.vault(request)
     // Handle success
     } catch let error as CoreSDKError {
        if error == CardError.threeDSecureCanceledError {
         // Handle 3DS Cancellation
        } else {
         // Handle other CoreSDKErrors
        }
     } catch {
       // Handle unexpected errors
     }
  }
```

### Best Practices 
- Take advantage of `Equatable` for simpler error comparisons
- Use the public error enum properties for better code clarity and type safety
- The helper methods `CardError.isThreeDSecureCanceled(Error)`, `PayPalError.isCheckoutCanceled(Error)`, `PayPalError.isVaultCanceled(Error)` are still available and are particularly useful if you only need to handle specific cases like cancellation and want to avoid casting to CoreSDKError in catch blocks:

```swift
// If you only care about handling cancellation, this might be simpler:
  do {
     let result = try await cardClient.vault(request)
     // Handle success
    } catch {
       if CardError.isThreeDSecureCanceled(error) {
        // Handle cancellation
       } else {
        // Handle other errors
       }
    }
```
 
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
                // handle errors
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
                // handle errors
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
* Note about using async/await functions: Our async/await functions utilize `withCheckedContinuation`
There were crashes reported in use of `withCheckedContinuation` with Xcode 16 beta 5+ with earlier iOS 18 beta versions.
Also there were reported issues with MacCatalyst apps using `withCheckedContinuation` built with Xcode 16 and running on MacOS 14-.
The fix for MacCatalyst apps was released with Xcode 16.2 beta.
https://github.com/swiftlang/swift/pull/76218#issuecomment-2377064768

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

### What's New in 2.0.0
- If you were already in 2.0.0-beta versions, the difference in 2.0.0 is that all completion blocks now return a single Result instead of two optionals. For example:
Using Completion Handlers
```swift
// 2.0.0-beta:
cardClient.approveOrder(request: cardRequest) { cardResult, error in
   if let error {
   // handle error
    return
  }
  if let cardResult {
    // Handle success
  }
}
```
```swift
// 2.0.0 GA:
cardClient.approveOrder(request: cardRequest) { cardResult, error in
   switch result {
    case .success(let cardResult):
    // handle success
    case .failure(let error):
    // handle error
   }
}
```
- Async/await function signatures remain the same from 2.0.0 beta versions