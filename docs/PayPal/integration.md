---
title: Pay with PayPal Custom Integration
keywords: 
contentType: docs
productStatus: current
apiVersion: TODO
sdkVersion: TODO
---

# Pay with PayPal Custom Integration

Follow these steps to add Card payments.

1. [Know before you code](#know-before-you-code)
1. [Add PayPal Payments](#add-paypal-payments)
1. [Test and go live](#test-and-go-live)

## Know before you code

You will need to set up authorization to use the PayPal Payments SDK. 
Follow the steps in [Get Started](https://developer.paypal.com/api/rest/#link-getstarted) to create a client ID. 

You will need a server integration to create an order and capture the funds using [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). 
For initial setup, the `curl` commands below can be used in place of a server SDK.

## Add PayPal Payments

### 1. Add the Payments SDK  to your app

#### Swift Package Manager

In Xcode, add the [package dependency](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) and enter https://github.com/paypal/iOS-SDK as the repository URL. Tick the checkboxes for the specific PayPal libraries you wish to include.

In your app's source code files, use the following import syntax to include PayPal's libraries:

```swift
import PayPal
```

#### CocoaPods

Include the PayPal pod in your `Podfile`.

```ruby
pod 'PayPal'
```

In your app's source code files, use the following import syntax to include PayPal's libraries:

```swift
import PayPal
```

### 2. Configure your application to present an authentication session

The PayPal payment flow utilizes an authentication session. Your `ViewController` must conform to the `ASWebAuthenticationPresentationContextProviding` protocol to enable this.

```swift
class MyViewController: ASWebAuthenticationPresentationContextProviding {

    // ASWebAuthenticationPresentationContextProviding conformance
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
        ?? ASPresentationAnchor()
    }
}
```

### 3. Create a PayPal button 

Add a `PayPalButton` to your View:

```swift
let payPalButton = PayPalButton()
```

### 4. Initiate the Payments SDK

Create a `CoreConfig` using your client ID from the PayPal Developer Portal:

```swift
let config = CoreConfig(clientID: "<CLIENT_ID>", environment: .sandbox)
```

Create a `PayPalClient` to approve an order with a PayPal payment method:

```swift
let payPalClient = PayPalClient(config: config)
```

### 5. Create an order

When a user enters the payment flow, call `v2/checkout/orders` to create an order and obtain an order ID:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic <ENCODED_CLIENT_ID>' \
--data-raw '{
    "intent": "<CAPTURE|AUTHORIZE>",
    "purchase_units": [
        {
            "amount": {
                "currency_code": "USD",
                "value": "5.00"
            }
        }
    ]
}'
```

The `id` field of the response contains the order ID to pass to your client.

### 6. Create a request object for launching the PayPal flow

Configure your `PayPalRequest` and include the order ID generated in [step 5](#5-create-an-order):

```swift
let payPalRequest = PayPalRequest(orderID: "<ORDER_ID>")
```

### 7. Approve the order through the Payments SDK

When a user taps the PayPal button created above, approve the order using your `PayPalClient`.

Add a target to your PayPal button to launch the PayPal payment flow:

```swift
payPalButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)

@objc func paymentButtonTapped() {
    checkoutWithPayPal(request: payPalRequest)
}
```

Call `PayPalClient.start` to approve the order, and then handle results:

```swift
func checkoutWithPayPal(request: PayPalRequest) {
    payPalClient.start(request: payPalRequest, context: self) { state in
        switch state {
        case .success(let result):
            // order was successfully approved and is ready to be captured/authorized (see step 8)
        case .failure(let error):
            // handle the error by accessing `error.localizedDescription`
        case .cancellation:
            // the user canceled
        }
    }
}
```

### 8. Capture/authorize the order

If you receive a successful result in the client-side flow, you can then capture or authorize the order. 

Call `authorize` to place funds on hold:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<ORDER_ID>/authorize' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic <ENCODED_CLIENT_ID>' \
--data-raw ''
```

Call `capture` to capture funds immediately:

```bash
curl --location --request POST 'https://api.sandbox.paypal.com/v2/checkout/orders/<ORDER_ID>/capture' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic <ENCODED_CLIENT_ID>' \
--data-raw ''
```

**Note**: Be sure that the endpoint you are calling aligns with the intent set on the order created in [step 4](#4-initiate-the-payments-sdk).

## Testing your integration

Follow the [Create sandbox accounts](https://developer.paypal.com/api/rest/#link-createsandboxaccounts) instructions to create PayPal test accounts.
When prompted to login with PayPal during the payment flow on your mobile app, you can log in with the test account credentials created above to complete the Sandbox payment flow. 

## Go live

Follow [these instructions](https://developer.paypal.com/api/rest/production/) to prepare your integration to go live.
