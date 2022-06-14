---
title: Pay with PayPal Custom Integration
keywords: 
contentType: docs
productStatus: current
apiVersion: TODO
sdkVersion: TODO
---

# Pay with PayPal Custom Integration

Follow these steps to add PayPal payments.

1. [Know before you code](#know-before-you-code)
1. [Add PayPal Payments](#add-paypal-payments)
1. [Test and go live](#test-and-go-live)

## Know before you code

You will need to set up authorization to use the PayPal Payments SDK. 
Follow the steps in [Get Started](https://developer.paypal.com/api/rest/#link-getstarted) to create a client ID. 

You will need a server integration to create an order to capture funds using the [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2). 
For initial setup, the `curl` commands below can be used as a reference for making server-side RESTful API calls.

## Add PayPal Payments

### 1. Add the Payments SDK  to your app

#### Swift Package Manager

In Xcode, follow the guide to [add package dependencies to your app](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) and enter https://github.com/paypal/iOS-SDK as the repository URL. Select the checkboxes for each specific PayPal library you wish to include in your project.

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PayPal
```

#### CocoaPods

Include the PayPal pod in your `Podfile`.

```ruby
pod 'PayPal'
```

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PayPal
```

### 2. Configure your application to present an authentication session

The PayPal payment flow uses an [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession). Make sure your `ViewController` conforms to the `ASWebAuthenticationPresentationContextProviding` protocol.

```swift
class MyViewController: ASWebAuthenticationPresentationContextProviding {

    // MARK: - ASWebAuthenticationPresentationContextProviding
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

### 3. Initiate the Payments SDK

Create a `CoreConfig` using your Client ID from the PayPal Developer Portal:

```swift
let config = CoreConfig(clientID: "<CLIENT_ID>", environment: .sandbox)
```

Create a `PayPalWebCheckoutClient` to approve an order with a PayPal payment method:

```swift
let payPalClient = PayPalWebCheckoutClient(config: config)
```

### 4. Create an order

When a user enters the payment flow, call `v2/checkout/orders` to create an order and obtain an Order ID:

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

The `id` field of the response contains the Order ID to pass to your client.

### 5. Create a request object for launching the PayPal flow

Configure your `PayPalWebCheckoutRequest` and include the order ID generated in [step 4](#4-create-an-order):

```swift
let payPalRequest = PayPalWebCheckoutRequest(orderID: "<ORDER_ID>")
```

You can also specify the funding source for your order which are `PayPal` (default), `PayLater` and `PayPalCredit`.
For more information go to: https://developer.paypal.com/docs/checkout/pay-later/us/

### 6. Approve the order through the Payments SDK

When a user initiates the PayPal payment flow through your UI, approve the order using your `PayPalWebCheckoutClient`.

Call `payPalClient.start()` to approve the order. Implement `PayPalWebCheckoutDelegate` in your `ViewController` to receive result notifications:

```swift
class MyViewController: ASWebAuthenticationPresentationContextProviding, PayPalWebCheckoutDelegate {
    ...

    func checkoutWithPayPal() {
        payPalClient.delegate = self
        payPalClient.start(request: payPalRequest, context: self)
    }

    // MARK: - PayPalWebCheckoutDelegate
    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithResult result: PayPalWebCheckoutResult) {
        // order was successfully approved and is ready to be captured/authorized (see step 7)
    }

    func payPal(_ payPalClient: PayPalWebCheckoutClient, didFinishWithError error: CoreSDKError) {
        // handle the error by accessing `error.localizedDescription`
    }

    func payPalDidCancel(_ payPalClient: PayPalWebCheckoutClient) {
        // the user canceled
    }
}
```

### 7. Capture/authorize the order

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

**Note**: Be sure that the endpoint you are calling aligns with the intent set on the order created in [step 3](#3-initiate-the-payments-sdk).

## Testing your integration

Follow the [Create sandbox account](https://developer.paypal.com/api/rest/#link-createsandboxaccounts) instructions to create a PayPal test account.
When prompted to login with PayPal during the payment flow on your mobile app, you can log in with Sandbox test account credentials to complete the Sandbox payment flow.

## Go live

Follow [these instructions](https://developer.paypal.com/api/rest/production/) to prepare your integration to go live.
